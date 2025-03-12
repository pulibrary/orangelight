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
      port = config['port'] || 5432
      sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} -p #{port} #{dbname} -c"

      conn = Faraday.new(url: solr_connection.to_s) do |faraday|
        faraday.options[:open_timeout] = 2000
        faraday.options[:timeout] = 2000
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      [sql_command, facet_request, conn]
    end

    def facet_request
      "#{core_url}select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field="
    end

    def solr_connection
      Blacklight.default_index.connection.uri
    end

    def output_root
      Pathname.new('/tmp')
    end

    def core_url
      solr_connection.to_s.gsub(%r{^.*/solr}, '/solr')
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

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def browse_subject(facet_request, conn, _facet_field, table_name)
      aat_genre_facet = 'aat_genre_facet'
      homoit_genre_facet = 'homoit_genre_facet'
      homoit_subject_facet = 'homoit_subject_facet'
      lcgft_genre_facet = 'lcgft_genre_facet'
      lc_subject_facet = 'lc_subject_facet'
      local_subject_facet = 'local_subject_facet'
      rbgenr_genre_facet = 'rbgenr_genre_facet'
      siku_subject_facet = 'siku_subject_facet'

      lc_subjects = JSON.parse(conn.get("#{facet_request}#{lc_subject_facet}").body)
      aat = JSON.parse(conn.get("#{facet_request}#{aat_genre_facet}").body)
      homoit_genre = JSON.parse(conn.get("#{facet_request}#{homoit_genre_facet}").body)
      homoit_subject = JSON.parse(conn.get("#{facet_request}#{homoit_subject_facet}").body)
      lcgft = JSON.parse(conn.get("#{facet_request}#{lcgft_genre_facet}").body)
      local_subject = JSON.parse(conn.get("#{facet_request}#{local_subject_facet}").body)
      rbgenr = JSON.parse(conn.get("#{facet_request}#{rbgenr_genre_facet}").body)
      siku = JSON.parse(conn.get("#{facet_request}#{siku_subject_facet}").body)

      # rubocop:disable Metrics/BlockLength
      CSV.open("/tmp/#{table_name}.csv", 'wb') do |csv|
        label = ''
        lc_subjects['facet_counts']['facet_fields'][lc_subject_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Library of Congress subject heading']
          end
        end
        aat['facet_counts']['facet_fields'][aat_genre_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Art & architecture thesaurus']
          end
        end
        homoit_genre['facet_counts']['facet_fields'][homoit_genre_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Homosaurus: an international LGBTQ linked data vocabulary']
          end
        end
        homoit_subject['facet_counts']['facet_fields'][homoit_subject_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Homosaurus: an international LGBTQ linked data vocabulary']
          end
        end
        lcgft['facet_counts']['facet_fields'][lcgft_genre_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Library of Congress genre/form terms for library and archival materials']
          end
        end
        local_subject['facet_counts']['facet_fields'][local_subject_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Locally assigned term']
          end
        end
        rbgenr['facet_counts']['facet_fields'][rbgenr_genre_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'Rare books genre term']
          end
        end
        siku['facet_counts']['facet_fields'][siku_subject_facet].each_with_index do |fac, index|
          if index.even?
            label = fac
          else
            csv << [label.normalize_em, fac.to_s, label, label.dir, 'SIKU subject heading']
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def load_facet(sql_command, _facet_request, _conn, facet_field, table_name)
      validate_csv(table_name)
      system(%(cp /tmp/#{table_name}.sorted /tmp/#{table_name}.sorted.backup))
      system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
      if facet_field == "subject_facet"
        system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir,vocabulary) from '/tmp/#{table_name}.csv' CSV;"))
        system(%(#{sql_command} "\\copy (Select sort,count,label,dir,vocabulary from #{table_name} order by unaccent(sort)) To '/tmp/#{table_name}.sorted' With CSV;"))
        system(%(#{sql_command} "TRUNCATE TABLE #{table_name} RESTART IDENTITY;"))
        system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir,vocabulary) from '/tmp/#{table_name}.sorted' CSV;"))
      else
        system(%(#{sql_command} "\\copy #{table_name}(sort,count,label,dir) from '/tmp/#{table_name}.csv' CSV;"))
        system(%(#{sql_command} "\\copy (Select sort,count,label,dir from #{table_name} order by unaccent(sort)) To '/tmp/#{table_name}.sorted' With CSV;"))
        load_facet_file(sql_command, "/tmp/#{table_name}.sorted", table_name)
      end
    end

    def validate_csv(table_name)
      csv_file_path = "/tmp/#{table_name}.csv"
      File.read(csv_file_path).each_line.count
      Rails.application.config_for(:orangelight)[:browse_lists][:csv_length]
      # raise StandardError, "CSV file too short - #{csv_length} lines long. Expected at least #{expected_length} lines." if csv_length < expected_length
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
