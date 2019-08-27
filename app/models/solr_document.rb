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
      id_values.map { |id| id.delete('#') }
    end

    def identifier_keys
      %w[
        isbn_s
        oclc_s
      ]
    end
end
