# frozen_string_literal: true

require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  class BrowseListFailed < StandardError; end
  class << self
    def connection
      config = Orangelight::Application.config.database_configuration[::Rails.env]
      dbhost = config['host']
      dbuser = config['username']
      dbname = config['database']
      password = config['password']
      sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} #{dbname} -c"

      # changes for different facet queries
      facet_request = "#{core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field="
      solr_url = Blacklight.connection_config[:url]
      # solr_url = 'http://lib-solr1.princeton.edu:8985'

      conn = Faraday.new(url: solr_url) do |faraday|
        faraday.options[:open_timeout] = 2000
        faraday.options[:timeout] = 2000
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      [sql_command, facet_request, conn]
    end

    def core_url
      Blacklight.default_index.connection.uri.to_s.gsub(%r{^.*\/solr}, '/solr')
    end

    def browse_facet(_sql_command, facet_request, conn, facet_field, table_name)
      resp = conn.get "#{facet_request}#{facet_field}"
      req = JSON.parse(resp.body)
      CSV.open("/tmp/#{table_name}.csv", 'wb') do |csv|
        label = ''
        req['facet_counts']['facet_fields'][facet_field.to_s].each_with_index do |fac, i|
          if i.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir]
          end
        end
      end
    end

    def browse_cn(_sql_command, facet_request, conn, facet_field, _table_name)
      resp = conn.get "#{facet_request}#{facet_field}&facet.mincount=2"
      req = JSON.parse(resp.body)
      CSV.open("/tmp/#{facet_field}.csv", 'wb') do |csv|
        mcn = ''
        multi_cns = {}
        req['facet_counts']['facet_fields'][facet_field.to_s].each_with_index do |f, i|
          if i.even?
            mcn = f
          else
            sort_cn = StringFunctions.cn_normalize(mcn)
            multi_cns[sort_cn] = f
            csv << [sort_cn, mcn, 'ltr', '', "#{f} titles with this call number", '', '', "?f[#{facet_field}][]=#{CGI.escape(mcn)}", '', 'Multiple locations']
          end
        end
        resp = conn.get "#{core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax"
        num_docs = JSON.parse(resp.body)['response']['numFound']
        rows = 500_000
        iterations = num_docs / rows + 1
        start = 0
        cn_fields = "#{facet_field},title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display"
        iterations.times do
          retries = 0
          cn_request = "#{core_url}select?q=*%3A*&fl=#{cn_fields}&wt=json&indent=true&defType=edismax&facet=false&sort=id%20asc&rows=#{rows}&start=#{start}"
          loop do
            resp = conn.get cn_request.to_s
            req = JSON.parse(resp.body)
            if req['response']
              req['response']['docs'].each do |record|
                next unless record[facet_field.to_s]
                record[facet_field.to_s].each_with_index do |cn, _i|
                  sort_cn = StringFunctions.cn_normalize(cn)
                  next if multi_cns.key?(sort_cn)
                  last_row = parse_call_number_row(record, cn, sort_cn)
                  csv << last_row
                end
              end
              start += rows
            else
              Rails.logger.error "Call number browse generation failed at iteration with start #{start}."
              Rails.logger.error "Response from solr was: #{resp}"
              Rails.logger.error "Last row was: #{last_row}"
              raise BrowseListFailed if retries >= 2
              retries += 1
            end
          end
        end
      end
    end

    def parse_call_number_row(record, cn, sort_cn)
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

    def load_facet(sql_command, _facet_request, _conn, _facet_field, table_name)
      system(%(cp /tmp/#{table_name}.sorted /tmp/#{table_name}.sorted.backup))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.csv' CSV;"))
      system(%(#{sql_command} \"\\copy (Select sort,count,label,dir from #{table_name} order by sort) To '/tmp/#{table_name}.sorted' With CSV;"))
      load_facet_file(sql_command, "/tmp/#{table_name}.sorted", table_name)
    end

    def load_cn(sql_command, _facet_request, _conn, facet_field, table_name)
      system(%(cp /tmp/#{facet_field}.sorted /tmp/#{facet_field}.sorted.backup))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid,holding_id,location) from '/tmp/#{facet_field}.csv' CSV;"))
      system(%(#{sql_command} "\\copy (Select sort,label,dir,scheme,title,author,date,bibid,holding_id,location from #{table_name} order by sort) To '/tmp/#{facet_field}.sorted' With CSV;"))
      load_cn_file(sql_command, "/tmp/#{facet_field}.sorted", table_name)
    end

    def load_facet_file(sql_command, sorted_file, table_name)
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '#{sorted_file}' CSV;"))
    end

    def load_cn_file(sql_command, sorted_file, table_name)
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid,holding_id,location) from '#{sorted_file}' CSV;"))
    end

    private

      # determines if there are multiple locations for the same call number and same bib
      def multiple_locations?(holdings)
        locations = holdings.reject { |_k, h| h['library'] == 'Online' }.map { |_k, h| h['location'] }.uniq
        locations.length > 1
      end
  end
end
