# frozen_string_literal: true

class Orangelight::Document::CitationComponent < Blacklight::Document::CitationComponent
  DEFAULT_FORMATS = {
    'blacklight.citation.mla': :export_as_mla,
    'blacklight.citation.apa': :export_as_apa_citation_txt,
    'blacklight.citation.chicago': :export_as_chicago_citation_txt
  }.freeze

  def initialize(document:, formats: DEFAULT_FORMATS)
    super
  end
end
