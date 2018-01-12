class StackmapLocationFactory
  # Constructor
  # @param resolver_service [Class] API for the resolution service
  def initialize(resolver_service:)
    @resolver_service = resolver_service
  end

  # Generates a URL using a Solr Document and holding information
  # @param document [SolrDocument] a Solr Document for the catalog record
  # @param location [Hash] location information for the holding
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the holding is located
  # @return [Object] the object modeling the resource to which the holding is resolved
  def resolve(document:, location:, call_number:, library:)
    return if excluded?(library) || call_number.nil?
    @resolver_service.new(document: document, loc: location, cn: call_number)
  end

  private

    # Whether or not a library should exclude a holding from having its location resolved
    # @param library [String] the library in which the holding resides
    # @return [TrueClass, FalseClass]
    def excluded?(library)
      [
        'Fine Annex',
        'Forrestal Annex',
        'Mudd Manuscript Library',
        'Online',
        'Rare Books and Special Collections',
        'ReCAP'
      ].include?(library)
    end
end
