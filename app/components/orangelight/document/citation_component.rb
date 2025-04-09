# frozen_string_literal: true

class Orangelight::Document::CitationComponent < Blacklight::Document::CitationComponent
  DEFAULT_FORMATS = {
    'blacklight.citation.mla': :export_as_mla,
    'blacklight.citation.apa': :export_as_apa,
    'blacklight.citation.chicago_author_date': :export_as_chicago_author_date,
    'blacklight.citation.chicago_notes_bibliography': :export_as_chicago_notes_bibliography
  }.freeze

  def initialize(document:, formats: DEFAULT_FORMATS)
    super
  end
end
