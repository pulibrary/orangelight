require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  class << self
    def connection
      config = Orangelight::Application.config.database_configuration[::Rails.env]
      dbhost = config['host']
      dbuser = config['username']
      dbname = config['database']
      password = config['password']
      sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} #{dbname} -c"

      # changes for different facet queries
      facet_request = '/solr/blacklight-core/select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field='
      solr_url = Blacklight.connection_config[:url]
      # solr_url = 'http://lib-solr1.princeton.edu:8985'

      conn = Faraday.new(url: solr_url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      [sql_command, facet_request, conn]
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
            csv << [sort_cn, mcn, 'ltr', '', "Click on the call number to see all #{f} records", '', '', "?f[#{facet_field}][]=#{mcn}", '', 'Multiple locations']
          end
        end
        resp = conn.get '/solr/blacklight-core/select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax'
        num_docs = JSON.parse(resp.body)['response']['numFound']
        rows = 1_000_000
        iterations = num_docs / rows + 1
        start = 0
        cn_fields = "#{facet_field},title_display,title_vern_display,author_display,id,pub_created_display,holdings_1display"
        iterations.times do
          cn_request = "/solr/blacklight-core/select?q=*%3A*&fl=#{cn_fields}&wt=json&indent=true&defType=edismax&facet=false&rows=#{rows}&start=#{start}"
          resp = conn.get cn_request.to_s
          req = JSON.parse(resp.body)
          req['response']['docs'].each do |record|
            next unless record[facet_field.to_s]
            record[facet_field.to_s].each_with_index do |cn, _i|
              sort_cn = StringFunctions.cn_normalize(cn)
              next if multi_cns.key?(sort_cn)
              bibid = record['id']
              title = record['title_display']
              if record['title_vern_display']
                title = record['title_vern_display']
                dir = title.dir
              else
                dir = 'ltr' # ltr for non alt script
              end
              label = cn
              author = record['author_display'][0..1].last if record['author_display']
              date = record['pub_created_display'][0..1].last if record['pub_created_display']
              if record['holdings_1display']
                holding_block = JSON.parse(record['holdings_1display'])
                holding_record = holding_block.select { |_k, h| h['call_number_browse'] == cn }
                unless holding_record.empty?
                  holding_id = holding_record.keys.first
                  location = holding_record[holding_id]['library']
                end
              end
              holding_id ||= ''
              location ||= ''
              csv << [sort_cn, label, dir, '', title, author, date, bibid, holding_id, location]
            end
          end
          start += rows
        end
      end
    end

    def load_facet(sql_command, _facet_request, _conn, _facet_field, table_name)
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.csv' CSV;"))
      system(%(#{sql_command} \"\\copy (Select sort,count,label,dir from #{table_name} order by sort) To '/tmp/#{table_name}.sorted' With CSV;"))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.sorted' CSV;"))
    end

    def load_cn(sql_command, _facet_request, _conn, facet_field, table_name)
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid,holding_id,location) from '/tmp/#{facet_field}.csv' CSV;"))
      system(%(#{sql_command} "\\copy (Select sort,label,dir,scheme,title,author,date,bibid,holding_id,location from #{table_name} order by sort) To '/tmp/#{facet_field}.sorted' With CSV;"))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid,holding_id,location) from '/tmp/#{facet_field}.sorted' CSV;"))
    end
  end
end
