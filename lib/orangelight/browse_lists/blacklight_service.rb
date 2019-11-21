# frozen_string_literal: true

require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'

module BrowseLists
  # @class Provides the query functionality for Blacklight
  class BlacklightService
    # Defines the default Solr fields requested in the query
    # @return [Array<String>]
    def self.default_blacklight_call_number_fields
      [
        'id',
        'title_display',
        'title_vern_display',
        'author_display',
        'author_s',
        'pub_created_vern_display',
        'pub_created_display',
        'holdings_1display',
        'call_number_browse_s'
      ]
    end

    def self.max_rows
      500_000
    end

    def solr_client
      Blacklight.default_index.connection
    end

    def blacklight_core_url
      solr_client.uri
    end

    # Request all Documents and specify a specific facet field
    # @param facet_field
    # @param mincount
    # @return [String]
    def blacklight_facet_request(facet_field, mincount = nil)
      solr_query = "*:*"

      http_query = {
        q: solr_query,
        fl: 'id',
        wt: 'json',
        indent: 'true',
        'defType' => 'edismax',
        'facet.sort' => 'asc',
        'facet.limit' => -1,
        'facet.field' => facet_field
      }
      http_query['facet.mincount'] = mincount unless mincount.nil?
      path = File.join(blacklight_core_url.path, 'select')

      request_uri = URI::Generic.build(
        scheme: blacklight_core_url.scheme,
        host: blacklight_core_url.host,
        port: blacklight_core_url.port,
        path: path,
        query: http_query.to_param
      )

      request_uri
    end

    # Request all Documents after a certain timestamp and specify a specific facet field
    # @param facet_field
    # @param time
    # @param mincount
    # @return [String]
    def blacklight_updated_facet_request(facet_field, updated_time, mincount = nil)
      solr_query = "*:*"

      http_query = {
        q: solr_query,
        fl: 'id',
        wt: 'json',
        indent: 'true',
        'defType' => 'edismax',
        'facet.sort' => 'asc',
        'facet.limit' => -1,
        'fq' => "timestamp:[#{updated_time} TO *]",
        'facet.field' => facet_field
      }
      http_query['facet.mincount'] = mincount unless mincount.nil?
      path = File.join(blacklight_core_url.path, 'select')

      request_uri = URI::Generic.build(
        scheme: blacklight_core_url.scheme,
        host: blacklight_core_url.host,
        port: blacklight_core_url.port,
        path: path,
        query: http_query.to_param
      )

      request_uri
    end

    def blacklight_response(request_url)
      solr_client.get(request_url.to_s)
    end
    alias :query_response :blacklight_response

    # Build a query for the Blacklight index
    # @param rows [Integer]
    # @param start [Integer]
    # @return [Hash]
    def blacklight_query(rows: nil, start: 0)
      rows ||= self.class.rows
      solr_query = "*:*"
      fl_values = self.class.default_blacklight_call_number_fields
      fl = fl_values.uniq.join(',')
      sort = 'id asc'

      {
        q: solr_query,
        fl: fl,
        wt: 'json',
        indent: 'true',
        defType: 'edismax',
        facet: 'false',
        sort: sort,
        rows: rows.to_s,
        start: start.to_s
      }
    end

    def blacklight_query_request(rows, start = 0)
      http_query = blacklight_query(rows: rows, start: start)

      blacklight_query_uri(http_query)
    end
    alias :find_all_query :blacklight_query_request

    # Build a query for the Blacklight index limited by a timestamp
    # @param [String] the Solr datestamp
    # @param rows [Integer]
    # @param start [Integer]
    # @return [Hash]
    def blacklight_updated_query(updated_time, rows, start = 0)
      http_query = blacklight_query(rows: rows, start: start)

      http_query[:fq] = "timestamp:[#{updated_time} TO *]"
      blacklight_query_uri(http_query)
    end

    def blacklight_updated_query_request(updated_time, rows, start = 0)
      http_query = blacklight_updated_query(updated_time, rows, start)

      blacklight_query_uri(http_query)
    end
    alias :find_updated_query :blacklight_updated_query_request

    def blacklight_query_uri(http_query)
      path = File.join(blacklight_core_url.path, 'select')

      URI::Generic.build(
        scheme: blacklight_core_url.scheme,
        host: blacklight_core_url.host,
        port: blacklight_core_url.port,
        path: path,
        query: http_query.to_param
      )
    end
  end
end
