# frozen_string_literal: true
require_relative 'solr_document/identifier'

class SolrDocument
  include Blacklight::Solr::Document
  include Orangelight::Document::Export
  include Orangelight::Document::Alma
  include Orangelight::Document::Scsb
  include Orangelight::Document::Dspace
  include Orangelight::Document::StandardNumbers

  # Explicitly required for sneakers
  include Blacklight::Document::Extensions
  include Blacklight::Document::SemanticFields

  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :id
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Marc::DocumentExtension) do |document|
    document.key?(:id)
  end

  field_semantics.merge!(
    title: 'title_citation_display',
    creator: 'author_citation_display',
    language: 'language_facet',
    format: 'format',
    description: 'summary_note_display',
    date: 'pub_date_start_sort',
    publisher: 'pub_created_display',
    subject: 'subject_facet',
    type: 'format',
    identifier: 'isbn_s'
  )

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core
  # document Semantic mappings of solr stored fields. Fields may be multi or single valued.
  # See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics and
  # Blacklight::Solr::Document#to_semantic_values.
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  ## Adds RIS
  use_extension(Blacklight::Document::Ris)

  ## Adds JSON-LD
  use_extension(Blacklight::Document::JsonLd)

  ## Adds the methods needed for CiteProc citations,
  # Including MLA, APA, and Chicago
  use_extension(Blacklight::Document::CiteProc)

  ## Adds MLA html
  use_extension(Blacklight::Document::Mla)

  # Adds APA html
  use_extension(Blacklight::Document::Apa)

  # Adds Chicago Author Date html
  use_extension(Blacklight::Document::ChicagoAuthorDate)

  # Adds Chicago Note Bibliography html
  use_extension(Blacklight::Document::ChicagoNotesBibliography)

  def identifier_data
    values = identifiers.each_with_object({}) do |identifier, hsh|
      hsh[identifier.data_key.to_sym] ||= []
      hsh[identifier.data_key.to_sym] << identifier.value
    end

    values[:'bib-id'] = id unless id.nil?
    values
  end

  def identifiers
    @identifiers ||= identifier_keys.flat_map do |key|
      fetch(key, []).map do |value|
        SolrDocument::Identifier.new(key, value)
      end
    end.compact
  end

  # Retrieve the value of the ARK identifier
  # @return [String] the ARK for the resource
  def ark
    return unless full_ark
    m = /.*(ark:(.*))/.match(full_ark)
    m[1]
  end

  def uuid?
    id.match?(/\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/)
  end

  # Retrieve the electronic access information
  # @return [Hash] electronic access value
  def doc_electronic_access
    catalog_url = "#{Rails.application.routes.url_helpers.url_for protocol: 'https', controller: 'catalog', host: ENV['APPLICATION_HOST'] || 'catalog.princeton.edu', action: 'show', id: id}#view"
    viewer_links = first('figgy_1display').present? ? { catalog_url => ['Digital content'] } : {}
    string_values = first('electronic_access_1display') || '{}'
    viewer_links.merge(JSON.parse(string_values).except('iiif_manifest_paths'))
  end

  # Retrieve electronic portfolio values and parse
  # @return [Array<Hash>] array of electronic portfolio hashes
  def electronic_portfolios
    values = fetch('electronic_portfolio_s', [])
    values.map { |v| JSON.parse(v) }
  end

  # Parse IIIF Manifest links from the electronic access information
  # @return [Hash] IIIF Manifests information
  def iiif_manifests
    string_values = first('electronic_access_1display') || '{}'
    values = JSON.parse(string_values)
    values.fetch('iiif_manifest_paths', {})
  end

  # IIIF Manifest URIs from the electronic access information
  # @return [Array<String>] URIs to IIIF Manifests
  def iiif_manifest_uris
    iiif_manifests.values
  end

  # The default IIIF Manifest URI from the electronic access information
  # @return [String] URIs to IIIF Manifests
  def iiif_manifest_uri
    iiif_manifest_uris.first
  end

  # Returns the MMS_IDs found in the electronic_access_1display display for URLs that follow the
  # pattern https://catalog.princeton.edu/catalog\{mms_id}#view except the one for the current ID.
  # These URLs are found when the Figgy manifest is registered for another (related) MMS_ID rather
  # than for the current one.
  def related_bibs_iiif_manifest
    @related_bibs_iiif_manifest ||= begin
      string_values = first('electronic_access_1display') || '{}'
      values = JSON.parse(string_values)
      mms_ids = values.keys.map { |key| key[/https\:\/\/catalog.princeton.edu\/catalog\/(\d*)#view/, 1] }.compact.uniq
      mms_ids.map { |id| ensure_voyager_to_alma_id(id) }.select { |mms_id| mms_id != id }
    end
  rescue => ex
    Rails.logger.error "Error calculating related_bibs_iiif_manifest for #{id}: #{ex.message}"
    []
  end

  # Makes sure an ID is an Alma ID or converts it to one if it is not.
  def ensure_voyager_to_alma_id(id)
    return id if id.length > 7 && id.start_with?("99")
    "99#{id}3506421"
  end

  # Retrieve the set of documents linked to this Object using a Solr Field
  # @param field [String] the field for this Object which contains the foreign document keys
  # @param query_field [String] the field in the linked documents to use as a key
  # @return [LinkedDocumentResolver::LinkedDocuments]
  def linked_records(field:, query_field: 'id', maximum_records: Orangelight.config['show_page']['linked_documents']['maximum'])
    sibling_ids = clean_ids(Array.wrap(fetch(field, [])))
    root_id = fetch(:id)
    LinkedDocumentResolver::LinkedDocuments.new(siblings: sibling_ids,
                                                root: root_id,
                                                solr_field: query_field,
                                                maximum_records:)
  end

  def full_arks
    electronic_access_uris.select { |x| x.include?('ark:') }
  end

  # Retrieves electronic portfolio values from sibling documents
  # @return [Array<Hash>] array of electronic portfolio hashes
  def sibling_electronic_portfolios
    sibling_documents.flat_map(&:electronic_portfolios)
  end

  def solr_document_id
    self["id"]
  end

  def host_id
    self["contained_in_s"].presence&.reject(&:empty?)
  end

  def bound_with?
    return true if host_id.present?
    false
  end

  def numismatics_record?
    solr_document_id&.start_with? 'coin'
  end

  def in_a_special_collection?
    return true if holdings_1display.blank?

    holdings_1display&.any? do |_holding_id, holding|
      location_code = holding[:location_code]
      holding_locations.dig(location_code, :aeon_location) if location_code
    end
  end

  # host_id an Array of host id(s)
  # Returns a hash of holdings from this record's host(s), if any
  # :reek:NestedIterators
  def host_holdings
    host_id&.reduce({}) do |all_holdings, id|
      host_holdings = JSON.parse(doc_by_id(id)&.dig("holdings_1display") || '{}')
      if host_holdings.blank?
        all_holdings
      else
        all_holdings.merge(
          host_holdings.transform_values { |holding| holding.merge("mms_id" => id) }
        )
      end
    end || {}
  end

  # Returns the holdings_1display of the record plus the holdings_1display of the host record
  def holdings_all_display
    holdings = JSON.parse(self["holdings_1display"] || '{}')
                   # append the solr document id in each holding
                   .transform_values { |holding| holding.merge("mms_id" => solr_document_id) }

    return holdings if host_id.blank?
    holdings.merge(host_holdings)
  end

  def physical_holding?
    holdings_all_display.length.positive?
  end

  def electronic_access?
    (doc_electronic_access.length + electronic_portfolios.length).positive?
  end

  def holdings_1display
    @holdings_1display ||= JSON.parse(self[:holdings_1display] || '{}', symbolize_names: true)
  end

  # @return [Boolean]
  def scsb_marcxml?
    return false unless scsb_record?

    marcxml_field.present?
  end

  # Fetch the marcxml field from Solr for this document
  # @return [String, nil]
  def marcxml_field
    self['marcxml']
  end

  # "cluster_members_s": ["99112222563506421","SCSB-9756116","SCSB-9431649"]
  def cluster_members
    self['cluster_members_s']
  end

  # "marcxml_s":[
  #       "{\"SCSB-9756116\": \"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\"}",
  #       "{\"SCSB-9431649\":\"H4sIAAAAAAAA/8VX227bOBD9FUJPu0AskRQlUVlHgFe7QVEkTVo3QNu3MUXbKnQxSDpx+vWl7NR1G4cmUBTVgyyYh2fODIcz5FhJ0asKbdqm0xfB0pjVeRQ9PDyETS/CRX8fXU/elZREuqnbYAc73+j6B+hDHPZqEVGMSfTh+moqlrKFUd1pA52Qdpauz/X2z6tegKn77pQldGR4YKtAVTpqQQmrJNpxPs0bpoUbXQXFuJFQSVVgglMioEVArbSYJqhGLMF4HD0BxqLvjOqbeS2bChlYXATWhaCYltN/RzmLScrycXQIOj4lDoo3b0ofZBIUFFNmdXH7m7I0xD7TeFAQjrl1kmLCkX1WCh08GGO0QnoFSPjQ5ZYuznIaJ/RneAUGDrEUB6juKnIRoO0HHT6KsV7PdijRV/IigKDIM05yRnOeJ9gG7RugGEd7yl9g31MzX+o48aT+66bsr8q/+45gZi0QzunvsvEbLXxfTz9i5hv528ndIedPgFlQyG7hAMigUBU4AOKUCbuhp+8v3YCb8qr0gNy4IR/vpm5AefOfd3ypZ3xXQnhz5p6cn8q7iS9p8jwR2PFEeJsxhsMpTd358IpnaKhSngII3gsgbq+m0Jlejy7lTEl9hq7hUcGZe8FInqYjd3bC2ix7FTpANhxP3aiu9s3o3jay2boB9Rgp2YDplY4slYMGH6PZWa9NLXXUQTu888zWe+5dQylLnsUPH43fq7UCAR1UgCL3htyGFv0Q79BXTsqe5RN5aTnR67V9nbvz6b2CGTS1PnNrHlLOV2SMfasfp2gFC6nRPyesEyRaX+tx6mndyI1xB8c4AXRbfIcGLzvjrS7zVLfuWlnVYGTl1tidVLjl8dbHPfXd9826lSe0idPhA6VqqTzlJd6pddvL1ntbpcnzg0D2Eq1Rj6HbrUYs5r9UqxayU/KyV639nNutx4bDLCd/yJ056BPePB3A5tpYrTTm1LtW5Jj41gpRJWTG5QgnJB+xKoMRSM5HcwpzjoGDyJk7G2nirjJzaLT01M2T/QkEO/rC8rCxo2+9e+GOZp5n9joSu53RQs/EuvGVm3kVRS/jw3E4SdPUXi8cKOs5cgx/DorJPdQNzBpXDVnZU+Fdbht2whl34IzV5Bje2H64BOUspV8GU47xJije/V9Obl+KeLS76hdfAcZNGoPzDwAA\"}"
  #   ],
  def marcxml_cluster
    self['marcxml_s']
  end

  private

    def electronic_access_uris
      electronic_access = first('electronic_access_1display')
      values = JSON.parse(electronic_access)
      uris = values.keys
      if values['iiif_manifest_paths']
        uris.delete('iiif_manifest_paths')
        uris += values['iiif_manifest_paths'].keys
      end
      uris
    rescue
      []
    end

    def full_ark
      full_arks.first
    end

    def clean_ids(id_values)
      out = id_values.map { |id| id.delete('#') }
      # Strip all non-ascii characters from ids
      out.map { |id| id.gsub(/[^[:ascii:]]/, "") }
    end

    def identifier_keys
      %w[
        isbn_s
        oclc_s
      ]
    end

    # Retrieves sibling documents linked by values on the other_version_s field
    # @return [Array<SolrDocument>] array of sibling solr documents
    def sibling_documents
      sibling_ids = clean_ids(Array.wrap(fetch('other_version_s', [])))
      root_id = fetch(:id)
      linked_documents = LinkedDocumentResolver::LinkedDocuments.new(siblings: sibling_ids,
                                                                     root: root_id,
                                                                     solr_field: 'other_version_s')
      linked_documents.siblings
    end

    def doc_by_id(id)
      params = { q: "id:#{RSolr.solr_escape(id)}" }
      solr_response = Blacklight.default_index.connection.get('select', params:)
      solr_response["response"]["docs"].first
    end

    def holding_locations
      @holding_locations ||= Bibdata.holding_locations
    end
end
