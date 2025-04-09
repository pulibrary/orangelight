# frozen_string_literal: true

# Creates an html ChicagoAuthorDate citation for non-Marc records
module Blacklight::Document::ChicagoAuthorDate
  def self.extended(document)
    Blacklight::Document::ChicagoAuthorDate.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:chicago_author_date, 'text/html')
  end

  def export_as_chicago_author_date
    cp = CiteProc::Processor.new style: 'chicago-author-date', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end
end
