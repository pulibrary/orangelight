# frozen_string_literal: true

module BrowseLists
  # @class structures and transmits requests for call number documents
  class CallNumberRequestService

    # determines if there are multiple locations for the same call number and same bib
    # @param [Hash] holdings
    # @return [Boolean]
    def self.multiple_locations?(holdings)
      locations = holdings.reject { |_k, h|
        h['library'] == 'Online'
      }.map { |_k, h|
        h['location']
      }.uniq
      locations.length > 1
    end

    # @constructor
    def initialize(blacklight_service:, model_name:, facet_field:)
      @blacklight_service = blacklight_service
      @model_name = model_name
      @facet_field = facet_field
      @multi_cns = {}
    end

    def self.max_rows
      500_000
    end

    def build_call_numbers_from_updated_documents(updated_time, initial_index)
      query = @blacklight_service.find_updated_query(updated_time, self.class.max_rows)
      iterations = find_iterations(query)
      retrieve_call_number_documents(query: query,
                                     iterations: iterations,
                                     rows: self.class.max_rows,
                                     start: 0,
                                     initial_index: initial_index,
                                     updated_time: updated_time)
    end

    def build_call_numbers_from_all_documents(initial_index)
      query = @blacklight_service.find_all_query(self.class.max_rows)
      iterations = find_iterations(query)
      retrieve_call_number_documents(query: query,
                                     iterations: iterations,
                                     rows: self.class.max_rows,
                                     start: 0,
                                     initial_index: initial_index)
    end

    def find_iterations(query)
      server_response = @blacklight_service.blacklight_response(query)
      response = server_response['response']
      num_found = response['numFound']
      num_found / self.class.max_rows + 1
    end

    def retrieve_call_number_documents(query:, iterations:, rows:, start:, initial_index:, updated_time: nil)
      call_number_documents = []

      index = 0
      iterations.times do
        query = if updated_time
                  @blacklight_service.find_updated_query(updated_time, rows, start)
                else
                  @blacklight_service.find_all_query(rows, start)
                end
        server_response = @blacklight_service.blacklight_response(query)
        response = server_response['response']
        docs = response['docs']

        docs.each do |record|
          next unless record[@facet_field.to_s]

          record[@facet_field.to_s].each do |cn|
            sort_cn = StringFunctions.cn_normalize(cn)
            # Skip this entry if there are multiple call numbers for this Document
            next if @multi_cns.key?(sort_cn)

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
                if self.class.multiple_locations?(holding_record)
                  location = 'Multiple locations'
                else
                  holding_id = holding_record.keys.first
                  location = holding_record[holding_id]['location']
                end
              end
            end

            call_number_document = build_document(
              id: label,
              model_name: @model_name,
              direction: dir,
              index: index + initial_index,
              sort_value: sort_cn,
              title: title,
              author: author,
              date: date,
              bibid: bibid,
              holding_id: holding_id,
              location: location
            )
            index += 1
            call_number_documents << call_number_document
          end
        end

        start += rows
      end

      call_number_documents
    end

    def build_document(id:, model_name:, direction:, index:, sort_value:,
                       title:, author: '', date: '', bibid:, holding_id: '',
                       location: '')
      {
        id: id,
        model_s: model_name,
        direction_s: direction,
        index_i: index,
        normalized_sort: sort_value,
        normalized_s: sort_value,
        title_s: title,
        author_s: author,
        date_s: date,
        bibid_s: bibid,
        holding_id_s: holding_id,
        location_s: location
      }
    end

    # Builds the Documents from call number facets
    def build_from_facet_counts(server_response)
      facet_counts = server_response['facet_counts']
      facet_fields = facet_counts['facet_fields']
      facet_entries = facet_fields[@facet_field.to_s]

      # First, query for call cases where the call numbers are faceted
      @multi_cns = {}
      call_number_documents = []

      facet = nil

      # This is for cases where the there are multiple records per call number
      # (Hence, these are stored within multiple locations)
      location = 'Multiple locations'
      index = 0

      facet_entries.each_with_index do |entry, entry_index|
        if entry_index.even?
          facet = entry
        else
          index += 1
          document_index = entry_index - index
          sort_cn = StringFunctions.cn_normalize(facet)
          @multi_cns[sort_cn] = entry

          title = "#{entry} titles with this call number"
          solr_query_facet_param = "?f[#{@facet_field}][]=#{CGI.escape(facet)}"

          dir = 'lts'
          call_number_document = build_document(
            id: facet,
            model_name: @model_name,
            direction: dir,
            index: document_index,
            sort_value: sort_cn,
            title: title,
            bibid: solr_query_facet_param,
            location: location
          )
          call_number_documents << call_number_document
        end
      end

      call_number_documents
    end
  end
end
