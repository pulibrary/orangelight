# frozen_string_literal: true

require 'csv'
require 'faraday'
require 'yajl/json_gem'
require './lib/orangelight/string_functions'
require_relative 'browse_lists/blacklight_service'
require_relative 'browse_lists/call_number_request_service'
require_relative 'browse_lists/facet_request_service'

module BrowseLists
  class << self
    def blacklight_service
      @blacklight_service ||= BlacklightService.new
    end

    def update_browse_call_numbers(facet_field, model_name, last_updated_time)
      request_date = Date.parse(last_updated_time)
      request_time = request_date.to_time_in_current_zone
      solr_request_time = request_time.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      request = blacklight_service.blacklight_updated_facet_request(facet_field, solr_request_time, 2)
      server_response = blacklight_service.blacklight_response(request)

      call_number_request_service = CallNumberRequestService.new(blacklight_service: blacklight_service, model_name: model_name, facet_field: facet_field)

      call_number_documents = call_number_request_service.build_from_facet_counts(server_response)

      initial_index = if call_number_documents.empty?
                        0
                      else
                        call_number_documents.last[:index_i]
                      end

      call_number_documents += call_number_request_service.build_call_numbers_from_updated_documents(solr_request_time, initial_index)

      solr_client.add(call_number_documents)
      solr_client.commit
    end

    def browse_call_numbers(facet_field, model_name)
      # Retrieve all of the facets with two or more Documents
      request = blacklight_service.blacklight_facet_request(facet_field, 2)
      server_response = blacklight_service.blacklight_response(request)

      call_number_request_service = CallNumberRequestService.new(blacklight_service: blacklight_service, model_name: model_name, facet_field: facet_field)

      call_number_documents = call_number_request_service.build_from_facet_counts(server_response)

      initial_index = if call_number_documents.empty?
                        0
                      else
                        call_number_documents.last[:index_i]
                      end

      blacklight_call_number_docs = call_number_request_service.build_call_numbers_from_all_documents(initial_index)

      # Iterate through the response records
      call_number_documents += blacklight_call_number_docs

      # @todo POST the results to the Solr Collection
      solr_client.add(call_number_documents)
      solr_client.commit
    end
    alias browse_cn browse_call_numbers
    delegate :solr_client, to: :blacklight_service

    def facet_request_service
      FacetRequestService.new(
        solr_client: solr_client,
        browse_list_document_builder: BrowseListDocument
      )
    end

    def update_browse_facet(facet_field, model_name, last_updated_time)
      request_date = Date.parse(last_updated_time)
      request_time = request_date.to_time_in_current_zone
      solr_request_time = request_time.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      request = blacklight_service.blacklight_updated_facet_request(facet_field, solr_request_time)
      response = blacklight_service.blacklight_response(request)

      facet_request_service.add_browse_facet(facet_field, model_name, response)
    end

    # Retrieves all of the browse facets
    def browse_facet(facet_field, model_name)
      request = blacklight_service.blacklight_facet_request(facet_field)
      response = blacklight_service.blacklight_response(request)

      facet_request_service.add_browse_facet(facet_field, model_name, response)
    end
  end
end
