# frozen_string_literal: true

# Creates an html Chicago citation for non-Marc records
module Blacklight::Document::Chicago
  def self.extended(document)
    Blacklight::Document::Chicago.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:chicago, 'text/html')
  end

  def export_as_chicago
    return export_as_chicago_citation_txt if alma?

    cp = CiteProc::Processor.new style: 'chicago-author-date', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end
end