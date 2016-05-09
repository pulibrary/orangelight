# -*- encoding : utf-8 -*-
class SolrDocument
  # include Blacklight::Folders::SolrDocument
  include Blacklight::Solr::Document
  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :id
  extension_parameters[:marc_format_type] = :marcxml
  use_extension(Blacklight::Solr::Document::Marc) do |document|
    document.key?(:id)
  end

  field_semantics.merge!(
    title: "title_display",
    author: "author_display",
    language: "language_facet",
    format: "format"
  )

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Solr::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Solr::Document::DublinCore)

  def identifier_data
    identifiers.each_with_object({}) do |identifier, hsh|
      hsh[identifier.data_key.to_sym] ||= []
      hsh[identifier.data_key.to_sym] << identifier.value
    end
  end

  def identifiers
    @identifiers ||= identifier_keys.flat_map do |key|
      fetch(key, []).map do |value|
        Identifier.new(key, value)
      end
    end.compact
  end

  private

    def identifier_keys
      [
        "isbn_s",
        "lccn_s",
        "oclc_s"
      ]
    end
end
