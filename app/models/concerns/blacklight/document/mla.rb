# frozen_string_literal: true

# Creates an html MLA citation for non-Marc records
module Blacklight::Document::Mla
  def self.extended(document)
    Blacklight::Document::Mla.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:mla, 'text/html')
  end

  def export_as_mla
    return export_as_mla_citation_txt if alma?

    cp = CiteProc::Processor.new style: 'modern-language-association', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end

  def properties
    props = {}
    props[:id] = id
    props[:edition] = mla_edition if mla_edition
    props[:type] = mla_type if mla_type
    props[:author] = mla_author if mla_author
    props[:title] = mla_title if mla_title
    props[:publisher] = mla_publisher if mla_publisher
    props[:'publisher-place'] = mla_publisher_place if mla_publisher_place
    props[:issued] = mla_issued if mla_issued
    props
  end

  def mla_type
    self[:format]&.first&.downcase
  end

  def mla_author
    @mla_author ||= begin
      family, given = citation_fields_from_solr[:author_citation_display]&.first&.split(', ')
      CiteProc::Name.new(family:, given:) if family || given
    end
  end

  def mla_edition
    @mla_edition ||= begin
      str = citation_fields_from_solr[:edition_display]&.first
      str&.dup&.sub!(/[[:punct:]]?$/, '')
    end
  end

  def mla_title
    @mla_title ||= citation_fields_from_solr[:title_citation_display]&.first
  end

  def mla_publisher
    @mla_publisher ||= citation_fields_from_solr[:pub_citation_display]&.first&.split(': ').try(:[], 1)
  end

  def mla_publisher_place
    @mla_publisher_place ||= citation_fields_from_solr[:pub_citation_display]&.first&.split(': ').try(:[], 0)
  end

  def mla_issued
    @mla_issued ||= citation_fields_from_solr[:pub_date_start_sort]
  end

  def citation_fields_from_solr
    @citation_fields_from_solr ||= begin
      params = { q: "id:#{RSolr.solr_escape(id)}", fl: "author_citation_display, title_citation_display, pub_citation_display, number_of_pages_citation_display, pub_date_start_sort, edition_display" }
      solr_response = Blacklight.default_index.connection.get('select', params:)
      solr_response["response"]["docs"].first.with_indifferent_access
    end
  end
end
