# frozen_string_literal: true

class DecoratorService
  # Decorator for SolrDocument Objects
  class SolrDocumentDecorator
    # Access the SolrDocument
    # @return [SolrDocument]
    attr_reader :document

    # Constructor
    # @param document [SolrDocument] the document
    # @param title_field [String] the field used for the title
    # @param display_fields [Array<String>] the fields displayed using the decorator
    def initialize(document:, title_field: 'title_display', display_fields: [])
      @document = document

      @title_field = title_field
      @display_fields = display_fields
    end

    # Retrieve a Hash containing fields as keys for field values
    # @return [Hash]
    def fields
      displayed_fields = @display_fields.select { |display_field| @document.key?(display_field) }
      pairs = displayed_fields.map do |display_field|
        [display_field, Array.wrap(@document.fetch(display_field))]
      end
      Hash[pairs]
    end

    # Access the title
    # @return [String]
    def title
      @document.fetch(@title_field, nil)
    end

    # Access the ID for the Solr Document
    # @return [String]
    def id
      @document.fetch('id')
    end
  end
end
