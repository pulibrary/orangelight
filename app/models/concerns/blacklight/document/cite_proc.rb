# frozen_string_literal: true

## Adds the methods needed for CiteProc citations,
# Including MLA, APA, and Chicago
module Blacklight::Document::CiteProc
  private

    def properties
      props = {}
      props[:id] = id
      props[:edition] = cite_proc_edition if cite_proc_edition
      props[:type] = cite_proc_type if cite_proc_type
      props[:author] = cite_proc_author if cite_proc_author
      props[:title] = cite_proc_title if cite_proc_title
      props[:publisher] = cite_proc_publisher if cite_proc_publisher
      props[:'publisher-place'] = cite_proc_publisher_place if cite_proc_publisher_place
      props[:issued] = cite_proc_issued if cite_proc_issued
      props
    end

    def cite_proc_type
      self[:format]&.first&.downcase
    end

    def cite_proc_author
      @cite_proc_author ||= begin
        family, given = citation_fields_from_solr[:author_citation_display]&.first&.split(', ')
        CiteProc::Name.new(family:, given:) if family || given
      end
    end

    def cite_proc_edition
      @cite_proc_edition ||= begin
        str = citation_fields_from_solr[:edition_display]&.first
        str&.dup&.sub!(/[[:punct:]]?$/, '')
      end
    end

    def cite_proc_title
      @cite_proc_title ||= citation_fields_from_solr[:title_citation_display]&.first
    end

    def cite_proc_publisher
      @cite_proc_publisher ||= citation_fields_from_solr[:pub_citation_display]&.first&.split(': ').try(:[], 1)
    end

    def cite_proc_publisher_place
      @cite_proc_publisher_place ||= citation_fields_from_solr[:pub_citation_display]&.first&.split(': ').try(:[], 0)
    end

    def cite_proc_issued
      @cite_proc_issued ||= citation_fields_from_solr[:pub_date_start_sort]
    end

    def citation_fields_from_solr
      @citation_fields_from_solr ||= begin
        params = { q: "id:#{RSolr.solr_escape(id)}", fl: "author_citation_display, title_citation_display, pub_citation_display, number_of_pages_citation_display, pub_date_start_sort, edition_display" }
        solr_response = Blacklight.default_index.connection.get('select', params:)
        solr_response["response"]["docs"].first.with_indifferent_access
      end
    end
end
