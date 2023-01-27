# frozen_string_literal: true

require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  class << self
    def table_prefix
      "alma_orangelight"
    end

    def connection
      config = Orangelight::Application.config.database_configuration[::Rails.env]
      dbhost = config['host']
      dbuser = config['username']
      dbname = config['database']
      password = config['password']
      port = config['port']
      sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} -p #{port} #{dbname} -c"

      conn = Faraday.new(url: solr_connection.to_s) do |faraday|
        faraday.options[:open_timeout] = 2000
        faraday.options[:timeout] = 2000
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.basic_auth(solr_user, solr_password) if basic_auth? # enable Solr auth
      end

      [sql_command, facet_request, conn]
    end

    def facet_request
      "#{core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field="
    end

    def solr_connection
      Blacklight.default_index.connection.uri
    end

    def solr_user
      solr_connection.user
    end

    def solr_password
      solr_connection.password
    end

    def basic_auth?
      solr_user && solr_password
    end

    def output_root
      Pathname.new('/tmp')
    end

    def core_url
      solr_connection.to_s.gsub(%r{^.*\/solr}, '/solr')
    end

    def browse_facet(_sql_command, facet_request, conn, facet_field, table_name)
      return browse_subject(facet_request, conn, facet_field, table_name) if facet_field == "subject_facet"
      resp = conn.get "#{facet_request}#{facet_field}"
      req = JSON.parse(resp.body)
      CSV.open(output_root.join("#{table_name}.csv"), 'wb') do |csv|
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

    def browse_subject(facet_request, conn, facet_field, table_name)
      subject_facet = 'subject_facet'
      lcgft_s = 'lcgft_s'
      rbgenr_s = 'rbgenr_s'
      # table_name = 'alma_orangelight_subjects'
      subjects = JSON.parse(conn.get("#{facet_request}#{subject_facet}").body)
      lcgft = JSON.parse(conn.get("#{facet_request}#{lcgft_s}").body)
      rbgenr = JSON.parse(conn.get("#{facet_request}#{rbgenr_s}").body)
      CSV.open("/tmp/#{table_name}.csv", 'wb') do |csv|
        label = ''
        subjects['facet_counts']['facet_fields'][subject_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Library of Congress subject heading']
          end
        end
        lcgft['facet_counts']['facet_fields'][lcgft_s].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Library of Congress genre/form term']
          end
        end
        rbgenr['facet_counts']['facet_fields'][rbgenr_s].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Rare books genre term']
          end
        end
      end
    end

    def load_facet(sql_command, _facet_request, _conn, _facet_field, table_name)
      system(%(cp /tmp/#{table_name}.sorted /tmp/#{table_name}.sorted.backup))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.csv' CSV;"))
      system(%(#{sql_command} \"\\copy (Select sort,count,label,dir from #{table_name} order by sort) To '/tmp/#{table_name}.sorted' With CSV;"))
      load_facet_file(sql_command, "/tmp/#{table_name}.sorted", table_name)
    end

    def load_subject(sql_command, _facet_request, _conn, _facet_field, table_name)
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir,vocabulary) from '/tmp/#{table_name}.csv' CSV;"))
      system(%(#{sql_command} \"\\copy (Select sort,count,label,dir,vocabulary from #{table_name} order by sort) To '/tmp/#{table_name}.sorted' With CSV;"))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir,vocabulary) from '/tmp/#{table_name}.sorted' CSV;"))
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
  end
end
