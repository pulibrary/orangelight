# frozen_string_literal: true

module BrowseLists
  # @class
  class FacetRequestService
    # Constructor
    # @param solr_client
    def initialize(solr_client:, browse_list_document_builder:)
      @solr_client = solr_client
      @browse_list_document_builder = browse_list_document_builder
    end

    delegate :build_from_facet, to: :@browse_list_document_builder
    alias build_document build_from_facet

    def add_browse_facet(facet_field, model_name, server_response)
      browse_documents = []

      facet_counts = server_response['facet_counts']
      facet_fields = facet_counts['facet_fields']
      facet_count_entries = facet_fields[facet_field.to_s]

      facet_count_entries.each_with_index do |entry, index|
        # Build the Document from the facet information
        if index.even?
          facet = entry
          browse_document = build_document(model_name: model_name, facet: facet, index: index)
          browse_documents << browse_document
        else
          browse_documents.last[:count_i] = entry
        end
      end

      @solr_client.add(browse_documents)
      @solr_client.commit
    end
  end
end
