require 'lcsort'
require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  class << self
    
    def get_connection
      config = Orangelight::Application.config.database_configuration[::Rails.env]
      dbhost, dbuser, dbname, password = config['host'], config['username'], config['database'], config['password']
      sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} #{dbname} -c"


      # changes for different facet queries
      facet_request = '/solr/blacklight-core/select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field='
      solr_url = Blacklight.connection_config[:url]
      #solr_url = 'http://lib-solr1.princeton.edu:8985'

      conn = Faraday.new(:url => solr_url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      return sql_command, facet_request, conn
    end


    def browse_facet(sql_command, facet_request, conn, facet_field, table_name)
      resp = conn.get "#{facet_request}#{facet_field}"
      req = JSON.parse(resp.body)
      CSV.open("/tmp/#{table_name}.csv", "wb") do |csv|
        label = ''
        req["facet_counts"]["facet_fields"]["#{facet_field}"].each_with_index do |fac, i|
          if i.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, StringFunctions.getdir(label)]
          end
        end           
      end 
    end  

    def browse_cn(sql_command, facet_request, conn, facet_field, table_name)
      resp = conn.get "#{facet_request}#{facet_field}&facet.mincount=2"
      req = JSON.parse(resp.body) 
      CSV.open("/tmp/#{facet_field}.csv", "wb") do |csv|
        mcn = ''
        multi_cns = {}
        req["facet_counts"]["facet_fields"]["#{facet_field}"].each_with_index do |f, i|
          if i.even?
            mcn = f
          else
            sort_cn = Lcsort.normalize(mcn)
            multi_cns[sort_cn] = f
            csv << [sort_cn, mcn, "ltr", "", "#{f} records for this call number", "", "", "?f[#{facet_field}][]=#{mcn}"]
          end
        end

        cn_fields = "#{facet_field},title_display,title_vern_display,author_display,id,pub_created_display"
        cn_request = "/solr/blacklight-core/select?q=*%3A*&fl=#{cn_fields}&wt=json&indent=true&defType=edismax&facet=false&rows=9999999"
        resp = conn.get "#{cn_request}"  
        req = JSON.parse(resp.body) 
        req["response"]["docs"].each do |record|
          if record["#{facet_field}"]
            record["#{facet_field}"].each_with_index do |cn, i|
              sort_cn = Lcsort.normalize(cn)                      
              unless multi_cns.has_key?(sort_cn)

                bibid = record["id"]
                title = record["title_display"][0] if record["title_display"]
                if record["title_vern_display"]
                  title = record["title_vern_display"] 
                  dir = StringFunctions.getdir(title)
                else
                  dir = "ltr"  #ltr for non alt script
                end
                label = cn
                author = record["author_display"][0..1].last if record["author_display"]
                date = record["pub_created_display"][0..1].last if record["pub_created_display"]
                csv << [sort_cn,label,dir,"",title,author,date,bibid]
              end
            end
          end        
        end
      end
    end

    def load_facet(sql_command, facet_request, conn, facet_field, table_name)
      system(%Q(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%Q(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.csv' CSV;"))
      system(%Q(#{sql_command} \"\\copy (Select sort,count,label,dir from #{table_name} order by sort) To '/tmp/#{table_name}.sorted' With CSV;"))
      system(%Q(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%Q(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.sorted' CSV;"))
    end

    def load_cn(sql_command, facet_request, conn, facet_field, table_name)
      system(%Q(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%Q(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid) from '/tmp/#{facet_field}.csv' CSV;"))
      system(%Q(#{sql_command} "\\copy (Select sort,label,dir,scheme,title,author,date,bibid from #{table_name} order by sort) To '/tmp/#{facet_field}.sorted' With CSV;"))
      system(%Q(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%Q(#{sql_command} "\\copy #{table_name}(sort,label,dir,scheme,title,author,date,bibid) from '/tmp/#{facet_field}.sorted' CSV;"))    
    end

  end
end