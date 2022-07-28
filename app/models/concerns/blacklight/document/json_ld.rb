# frozen_string_literal: true

module Blacklight::Document::JsonLd
  def self.extended(document)
    # Register our exportable formats
    Blacklight::Document::JsonLd.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:jsonld, 'application/ld+json')
  end

  def export_as_jsonld
    data.to_json
  end

  def data
    metadata = {}
    metadata["@context"] = "http://bibdata.princeton.edu/context.json"
    metadata["@id"] = Rails.application.routes.url_helpers.solr_document_url(id: self['id'], host: default_host)
    metadata["title"] = title
    metadata["language"] = title_language
    metadata_map.each do |solr_key, metadata_key|
      values = self[solr_key.to_s] || []
      values = values.first if values.size == 1
      metadata[metadata_key] = values unless values.empty?
    end

    metadata
  end

  # rubocop:disable Metrics/MethodLength
  def metadata_map
    {
      author_display: 'creator',
      call_number_display: 'call_number',
      description_display: 'extent',
      edition_display: 'edition',
      format: 'format',
      genre_facet: 'type',
      notes_display: 'description',
      pub_created_display: 'publisher',
      subject_facet: 'subject',
      coverage_display: 'coverage',
      title_sort: 'title_sort',
      alt_title_246_display: 'alternative',
      scale_display: 'cartographic_scale',
      projection_display: 'cartographic_projection',
      geocode_display: 'spatial',
      contents_display: 'contents',
      geo_related_record_display: 'relation',
      uniform_title_s: 'uniform_title',
      language_display: 'text_language',
      binding_note_display: 'binding_note',
      provenance_display: 'provenance',
      source_acquisition_display: 'source_acquisition',
      references_display: 'references',
      indexed_in_display: 'indexed_by'
    }
  end
  # rubocop:enable Metrics/MethodLength

  def title
    return [vernacular_title, roman_title] if vernacular_title
    [roman_title]
  end

  def vernacular_title
    vtitle = self['title_vern_display']
    return unless vtitle

    {
      '@value' => vtitle,
      '@language' => title_language
    }
  end

  def roman_title
    lang = title_language
    lang = "#{lang}-Latn" if lang && vernacular_title.present?
    {
      '@value' => self['title_display'],
      '@language' => lang
    }
  end

  def title_language
    self['language_code_s'].first
  end

  def default_host
    @default_host ||= "#{ENV['APPLICATION_HOST_PROTOCOL'] || 'http'}://#{ENV['APPLICATION_HOST'] || 'localhost:3000'}" || 'http://localhost'
  end
end
