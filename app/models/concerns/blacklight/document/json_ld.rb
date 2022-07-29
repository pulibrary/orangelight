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
    metadata["@context"] = "#{default_host}/context.json"
    metadata["@id"] = Rails.application.routes.url_helpers.solr_document_url(id: self['id'], host: default_host)
    metadata["title"] = title
    metadata["language"] = title_language
    metadata_map.each do |solr_key, metadata_key|
      values = self[solr_key.to_s] || []
      values = values.first if values.size == 1
      metadata[metadata_key] = values unless values.empty?
    end
    metadata.merge!(contributors)
    metadata.merge! creator
    metadata['created'] = date(true) if date(true)
    metadata['date'] = date if date
    metadata['abstract'] = abstract if abstract
    metadata['identifier'] = identifier if identifier
    metadata['local_identifier'] = local_identifier if local_identifier
    metadata['location'] = location if location
    metadata['electronic_locations'] = electronic_links if electronic_links.present?

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

  def contributors
    related_name_display = self['related_name_json_1display']
    return {} unless related_name_display

    contributors = {}
    JSON.parse(related_name_display).each do |role, names|
      contributors[check_role(role)] = names
    end
    contributors
  end

  def creator
    role = check_role((self['marc_relator_display'] || []).first)
    return { role => self['author_display'].first } unless role == 'contributor'
    {}
  end

  def check_role(label)
    role = (label || '').parameterize(separator: '_').singularize
    RELATORS.include?(role) ? role : 'contributor'
  end

  def date(expanded = false)
    return self['compiled_created_display'].first if expanded == false && self['compiled_created_display']
    return unless self['pub_date_start_sort']
    date = self['pub_date_start_sort'].to_s
    date += "-01-01T00:00:00Z" if expanded
    end_date = self['pub_date_end_sort'].to_s || ''
    unless end_date.empty?
      date += expanded ? "/" + end_date + "-12-31T23:59:59Z" : "-" + end_date
    end

    date
  end

  def abstract
    (self['summary_note_display'] || []).first
  end

  # Numbers from the Digital Cicognara Library (DCL)
  def local_identifier
    return unless self['standard_no_1display']

    json = JSON.parse(self['standard_no_1display'])
    json['Dclib']
  end

  # Arks from the electronic_access_1display
  def identifier
    return unless electronic_locations

    electronic_locations.each do |_key, val|
      foo = val.select { |x| x.to_s.include?('ark') }
      next if foo.blank?

      return foo.keys.first
    end
  end

  def electronic_locations
    return unless self['electronic_access_1display']

    JSON.parse(self['electronic_access_1display'])
  end

  def location
    return unless self['location'] && self['call_number_display']

    values = []
    self['location'].each do |location_code|
      self['call_number_display'].each do |call_number|
        values << "#{location_code} #{call_number}"
      end
    end
    values
  end

  def electronic_links
    @electronic_links ||= begin
      return unless electronic_locations

      electronic_locations.map do |uri, label|
        {
          "@id" => uri,
          "label" => label
        }
      end
    end
  end

  def default_host
    @default_host ||= "#{ENV['APPLICATION_HOST_PROTOCOL'] || 'http'}://#{ENV['APPLICATION_HOST'] || 'localhost:3000'}" || 'http://localhost'
  end
end
