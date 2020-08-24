# frozen_string_literal: true

module BrowseLists
  class CallNumberCSV
    attr_reader :output_root, :facet_request, :conn, :rows
    attr_accessor :multi_cn_lookup
    def initialize(facet_request, conn, output_root, rows: 250_000)
      @output_root = output_root
      @facet_request = facet_request
      @conn = conn
      @rows = rows
      @multi_cn_lookup = {}
    end

    def write
      write_multiple_call_numbers
      write_single_call_numbers
    end

    def filename
      output_root.join("#{facet_field}.csv")
    end

    private

      def core_url
        Blacklight.default_index.connection.uri.to_s.gsub(%r{^.*\/solr}, '/solr')
      end

      def facet_field
        "call_number_browse_s"
      end

      # Collect all the call numbers with facet count > 2
      # Write each as a row in the csv and add it to the lookup table
      def write_multiple_call_numbers
        # This request takes a minute or so
        resp = conn.get "#{facet_request}#{facet_field}&facet.mincount=2"
        req = JSON.parse(resp.body)
        CSV.open(filename, 'wb') do |csv|
          req['facet_counts']['facet_fields'][facet_field].each_slice(2) do |mcn, record_count|
            sort_cn = StringFunctions.cn_normalize(mcn)
            multi_cn_lookup[sort_cn] = record_count
            csv << [sort_cn, mcn, 'ltr', '', "#{record_count} titles with this call number", '', '', "?f[#{facet_field}][]=#{CGI.escape(mcn)}", '', 'Multiple locations']
          end
        end
      end

      # Append the rest of the call numbers to the file
      def write_single_call_numbers
        start = 0
        cn_fields = "#{facet_field},title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display"

        CSV.open(filename, 'ab') do |csv|
          iterations.times do
            # Get the actual items
            cn_request = "#{core_url}select?q=*%3A*&fl=#{cn_fields}&wt=json&indent=true&defType=edismax&facet=false&sort=id%20asc&rows=#{rows}&start=#{start}"
            resp = conn.get cn_request.to_s
            req = JSON.parse(resp.body)
            req['response']['docs'].each do |record|
              next unless record[facet_field]
              record[facet_field].each do |cn|
                sort_cn = StringFunctions.cn_normalize(cn)
                next if multi_cn_lookup.key?(sort_cn)
                csv << parse_cn_row(record, cn, sort_cn)
              end
            end
            start += rows
          end
        end
      end

      # calculate the number of pages to fetch from solr
      def iterations
        # Get count of all items in the index
        resp = conn.get "#{core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax"
        num_docs = JSON.parse(resp.body)['response']['numFound']
        if (num_docs % rows).zero?
          num_docs / rows
        else
          num_docs / rows + 1
        end
      end

      def parse_cn_row(record, cn, sort_cn)
        bibid = record['id']
        title = record['title_display']
        if record['title_vern_display']
          title = record['title_vern_display']
          dir = title.dir
        else
          dir = 'ltr' # ltr for non alt script
        end
        if record['pub_created_vern_display']
          date = record['pub_created_vern_display'][0]
        elsif record['pub_created_display'].present?
          date = record['pub_created_display'][0]
        end
        label = cn
        if record['author_display']
          author = record['author_display'][0..1].last
        elsif record['author_s']
          author = record['author_s'][0]
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
        [sort_cn, label, dir, '', title, author, date, bibid, holding_id, location]
      end

      # determines if there are multiple locations for the same call number and same bib
      def multiple_locations?(holdings)
        locations = holdings.reject { |_k, h| h['library'] == 'Online' }.map { |_k, h| h['location'] }.uniq
        locations.length > 1
      end
  end
end
