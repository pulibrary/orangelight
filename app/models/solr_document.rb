# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include Orangelight::Document::Export

  # Explicitly required for sneakers
  include Blacklight::Document::Extensions
  include Blacklight::Document::SemanticFields

  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :id
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Solr::Document::Marc) do |document|
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

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core
  # document Semantic mappings of solr stored fields. Fields may be multi or single valued.
  # See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics and
  # Blacklight::Solr::Document#to_semantic_values.
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  ## Adds RIS
  use_extension(Blacklight::Document::Ris)

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
        Identifier.new(key, value)
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

  # Retrieve the electronic access information
  # @return [String] electronic access value
  def doc_electronic_access
    string_values = first('electronic_access_1display') || '{}'
    JSON.parse(string_values).delete_if { |k, _v| k == 'iiif_manifest_paths' }
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
  def linked_records(field:, query_field: 'id')
    sibling_ids = clean_ids(Array.wrap(fetch(field, [])))
    root_id = fetch(:id)
    linked_documents = LinkedDocumentResolver::LinkedDocuments.new(siblings: sibling_ids,
                                                                   root: root_id,
                                                                   solr_field: query_field)
    linked_documents.decorated(display_fields: %w[id])
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
    self["contained_in_s"].reject(&:empty?) if self["contained_in_s"].present?
  end

  def bound_with?
    return true if host_id.present?
    false
  end

  # host_id an Array of host id(s)
  # appends the host_id in each host_holding
  # merges host_holding in holdings
  def holdings_with_host_id(holdings)
    host_id.each do |id|
      host_solr_document = doc_by_id(id)
      host_holdings = host_solr_document&.dig("holdings_1display")
      host_holdings_parse = JSON.parse(host_holdings)
      host_holding_id = host_holdings_parse.first[0]
      # append the host_id as mms_id in the host_holdings
      host_holdings_parse[host_holding_id]["mms_id"] = id

      holdings.merge!(host_holdings_parse) if host_holdings_parse.present? # do not merge an empty holding
    end
  end

  # Returns the holdings_1display of the record plus the holdings_1display of the host record
  def holdings_all_display
    holdings = JSON.parse(self["holdings_1display"] || '{}')

    holdings.each do |k, _val|
      # append the solr document id in each holding
      holdings[k].merge!("mms_id" => solr_document_id) if holdings[k].present?
    end
    return holdings unless host_id.present?
    # Append the host_id in the host_holdings
    # merge the host_holdings in holdings
    holdings_with_host_id(holdings)
    holdings
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
      solr_response = Blacklight.default_index.connection.get('select', params: params)
      solr_response["response"]["docs"].first
    end
end
