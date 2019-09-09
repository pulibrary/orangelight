# frozen_string_literal: true

class LinkedDocumentResolver
  # A mutable array of Solr Documents linked to a given Solr Document
  class LinkedDocuments
    delegate :empty?, to: :siblings

    # Constructor
    # @param root [String] the identifier for the record
    # @param siblings [Array<String>] the identifiers for the related records
    # @param solr_field [String] the Solr field containing the sibling values
    def initialize(root:, siblings:, solr_field:)
      @root = root
      @siblings = siblings
      @field = solr_field
    end

    # Retrieves the Solr documents for each adjacent node
    # @return [Array<SolrDocument>] sibling documents
    def siblings
      return [] unless @siblings.present? && response.key?('response') &&
                       !response['response']['docs'].empty?

      sibling_docs = response['response']['docs'].reject { |document| document['id'] == @root }
      sibling_docs.map { |document| SolrDocument.new(document) }
    end

    # Decorate the SolrDocument for each sibling node decorated for the View layer
    # @param title_field [String] field used to access the value of the title for the catalog record
    # @param display_fields [Array<String>] the set of fields exposed for the catalog record
    # @return [Array<SolrDocumentDecorator>] sibling document
    def decorated(title_field: 'title_display', display_fields: [])
      siblings.map do |sibling|
        DecoratorService::SolrDocumentDecorator.new(document: sibling,
                                                    title_field: title_field,
                                                    display_fields: display_fields)
      end
    end

    private

      # Determine whether or not this number is a BIBID
      # @param sibling_number [String] reference number for a linked catalog record
      # @return [MatchData,nil] a match containing the ID for the linked BIBID (or nil)
      def bib_id?(sibling_number)
        /(?:^BIB)(.*)/.match(sibling_number)
      end

      # The Solr field containing the reference number for a linked catalog record
      # @param sibling_number [String] reference number for a linked catalog record
      # @return [String] the field
      def solr_field(sibling_number)
        bib_id?(sibling_number) ? 'id' : @field
      end

      # The value for the Solr field referencing the linked catalog record
      # @param sibling_number [String] reference number for a linked catalog record
      # @return [String] the value
      def solr_value(sibling_number)
        bib_match = bib_id?(sibling_number)
        bib_match ? bib_match[1] : sibling_number
      end

      # The query for used to retrieve Documents for all catalog records linked to a given record
      # @return [String] the query
      def facet_query
        queries = @siblings.map do |sibling_number|
          "#{solr_field(sibling_number)}:#{solr_value(sibling_number)}"
        end
        queries.join(' OR ')
      end

      # Retrieve an instance of the FacetedQueryService
      # @return [FacetedQueryService] an instance of the service object
      def faceted_query_service
        @faceted_query_service ||= FacetedQueryService.new(Blacklight)
      end

      # The response from Solr from the facet query for all linked documents
      # @return [Hash] the response (parsed from JSON)
      def response
        return @response unless @response.nil?

        http_response = faceted_query_service.get_fq_solr_response(facet_query)
        @response = JSON.parse(http_response.body)
      end
  end
end
