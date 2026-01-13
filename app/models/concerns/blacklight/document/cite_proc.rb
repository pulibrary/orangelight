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
      props[:author] = cite_proc_authors if cite_proc_authors
      props[:title] = cite_proc_title if cite_proc_title
      props[:publisher] = cite_proc_publisher if cite_proc_publisher
      props[:'publisher-place'] = cite_proc_publisher_place if cite_proc_publisher_place
      props[:issued] = cite_proc_issued if cite_proc_issued
      props
    end

    def cite_proc_type
      self[:format]&.first&.downcase
    end

    def cite_proc_authors
      @cite_proc_authors ||= cleaned_authors&.map do |author|
        if author.include?(', ')
          family, given = author.split(', ')
          CiteProc::Name.new(family:, given:)
        else
          CiteProc::Name.new(literal: author)
        end
      end
    end

    # Can remove after https://github.com/pulibrary/bibdata/issues/2646 is completed & re-indexed
    def cleaned_authors
      self[:author_citation_display]&.map do |author|
        # remove any parenthetical statements from author, as used for Corporate authors in Marc
        author.sub(/ \(.*\)/, '')
      end
    end

    def cite_proc_edition
      @cite_proc_edition ||= begin
        str = self[:edition_display]&.first
        str&.dup&.sub!(/[[:punct:]]?$/, '')
      end
    end

    def cite_proc_title
      @cite_proc_title ||= self[:title_citation_display]&.first
    end

    def cite_proc_publisher
      @cite_proc_publisher ||= begin
        publisher = self[:pub_citation_display]&.first&.split(': ').try(:[], 1)
        publisher&.gsub(/^<(.*)>$/, '\1')
      end
    end

    def cite_proc_publisher_place
      @cite_proc_publisher_place ||= self[:pub_citation_display]&.first&.split(': ').try(:[], 0)
    end

    def cite_proc_issued
      @cite_proc_issued ||= self[:pub_date_start_sort]
    end
end
