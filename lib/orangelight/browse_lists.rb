# frozen_string_literal: true

require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  class << self
    def connection_uri
      Orangelight.browse_lists_index.connection.uri
    end

    def solr_client
      Orangelight.browse_lists_index.connection
    end

    def blacklight_solr_connection
      Blacklight.connection_config[:url]
    end

    # Isn't this the same as above?
    def blacklight_core_url
      Blacklight.default_index.connection.uri
    end

    def blacklight_http_client
      @blacklight_http_client ||= Faraday.new(url: blacklight_core_url) do |faraday|
        faraday.options[:open_timeout] = 2000
        faraday.options[:timeout] = 2000
        faraday.request(:url_encoded)
        faraday.response(:logger)
        faraday.adapter(Faraday.default_adapter)
      end
    end

    def blacklight_facet_request(facet_field, mincount = nil)
      request = "#{blacklight_core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field=#{facet_field}"

      request = "#{request}&facet.mincount=#{mincount}" unless mincount.nil?
      request
    end

    def blacklight_response(request_url)
      response = blacklight_http_client.get(request_url)
      JSON.parse(response.body)
    end

    def blacklight_query_request(query, fields = "id")
      query_param = CGI.escape(query)
      fields_param = CGI.escape(fields)
      "#{blacklight_core_url}select?q=#{query_param}&fl=#{fields_param}&wt=json&indent=true&defType=edismax"
    end

    def blacklight_call_number_query_request(facet_field, rows = 10, start = 0)
      fields = "#{facet_field},title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display"
      request = blacklight_query_request("*.*", fields)
      rows_param = CGI.escape(rows.to_s)
      start_param = CGI.escape(start.to_s)
      "#{request}&facet=false&sort=id%20asc&rows=#{rows_param}&start=#{start_param}"
    end

    def browse_facet(facet_field, model_name)
      request = blacklight_facet_request(facet_field)
      response = blacklight_response(request)

      browse_documents = []

      facet_counts = response['facet_counts']
      facet_fields = facet_counts['facet_fields']
      facet_count_entries = facet_fields[facet_field.to_s]

      facet_count_entries.each_with_index do |entry, index|
        # Build the Document from the facet information
        if index.even?
          facet = entry

          browse_document = {
            id: facet,
            model_s: model_name,
            index_i: index,
            facet_field.to_s => facet.to_s,
            normalized_sort: facet.normalize_em,
            direction_s: facet.dir
          }
          browse_documents << browse_document
        else
          browse_documents.last[:count_i] = entry
        end
      end

      solr_client.add(browse_documents)
      solr_client.commit
    end

    # rubocop:disable Metrics/ParameterLists
    def request_blacklight_call_numbers(facet_field,
                                        iterations,
                                        rows,
                                        start,
                                        multi_cns,
                                        model_name,
                                        initial_index)

      call_number_documents = []

      index = 0
      iterations.times do
        request = blacklight_call_number_query_request(facet_field, rows, start)
        req = blacklight_response(request)

        req['response']['docs'].each do |record|
          next unless record[facet_field.to_s]

          record[facet_field.to_s].each do |cn|
            sort_cn = StringFunctions.cn_normalize(cn)
            # Skip this entry if there are multiple call numbers for this Document
            next if multi_cns.key?(sort_cn)

            bibid = record['id']
            title = record['title_display']
            if record['title_vern_display']
              title = record['title_vern_display']
              dir = title.dir
            else
              dir = 'ltr' # ltr for non alt script
            end
            if record['pub_created_vern_display']
              date = record['pub_created_vern_display'].first
            elsif record['pub_created_display'].present?
              date = record['pub_created_display'].first
            end
            label = cn
            if record['author_display']
              author = record['author_display'][0..1].last
            elsif record['author_s']
              author = record['author_s'].first
            end
            if record['holdings_1display']
              holding_block = JSON.parse(record['holdings_1display'])
              holding_record = holding_block.select { |_k, h| h['call_number_browse'] == cn }
              unless holding_record.empty?
                if multiple_locations?(holding_record)
                  location = 'Multiple locations'
                else
                  holding_id = holding_record.keys.first
                  location = holding_record[holding_id]['location']
                end
              end
            end

            holding_id ||= ''
            location ||= ''

            call_number_document = {
              id: label,
              model_s: model_name,
              direction_s: dir,
              index_i: index + initial_index,
              normalized_sort: sort_cn,
              normalized_s: sort_cn,

              title_s: title,
              author_s: author,
              date_s: date,
              bibid_s: bibid,
              holding_id_s: holding_id,
              location_s: location
            }
            index += 1
            call_number_documents << call_number_document
          end
        end

        start += rows
      end

      call_number_documents
    end
    # rubocop:enable Metrics/ParameterLists

    def browse_call_numbers(facet_field, model_name)
      request = blacklight_facet_request(facet_field, 2)
      req = blacklight_response(request)

      # First, query for call cases where the call numbers are faceted
      multi_cns = {}
      call_number_documents = []

      facet = nil

      # This is for cases where the there are multiple records per call number
      # (Hence, these are stored within multiple locations)
      location = 'Multiple locations'
      i = 0
      req['facet_counts']['facet_fields'][facet_field.to_s].each_with_index do |entry, index|
        if index.even?
          facet = entry
        else
          i += 1
          document_index = index - i
          sort_cn = StringFunctions.cn_normalize(facet)
          multi_cns[sort_cn] = entry

          title = "#{entry} titles with this call number"
          solr_query_facet_param = "?f[#{facet_field}][]=#{CGI.escape(facet)}"

          call_number_document = {
            id: facet,
            model_s: model_name,
            direction_s: 'ltr',
            index_i: document_index,
            normalized_sort: sort_cn,
            normalized_s: sort_cn,
            title_s: title,
            author_s: '',
            date_s: '',
            bibid_s: solr_query_facet_param,
            holding_id_s: '',
            location_s: location
          }
          call_number_documents << call_number_document
        end
      end

      # Request all of the Documents in the Blacklight Solr collection
      request = blacklight_query_request("*.*")
      resp = blacklight_response(request)
      num_docs = resp['response']['numFound']
      rows = 500_000
      iterations = num_docs / rows + 1
      start = 0
      initial_index = if call_number_documents.empty?
                        0
                      else
                        call_number_documents.last[:index_i]
                      end

      # Iterate through the response records
      call_number_documents += request_blacklight_call_numbers(facet_field, iterations, rows, start, multi_cns, model_name, initial_index)

      # @todo POST the results to the Solr Collection
      solr_client.add(call_number_documents)
      solr_client.commit
    end
    alias browse_cn browse_call_numbers

    private

      # determines if there are multiple locations for the same call number and same bib
      def multiple_locations?(holdings)
        locations = holdings.reject { |_k, h| h['library'] == 'Online' }.map { |_k, h| h['location'] }.uniq
        locations.length > 1
      end
  end
end
