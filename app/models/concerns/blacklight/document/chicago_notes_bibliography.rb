# frozen_string_literal: true

# Creates an html ChicagoNoteBibliography citation for non-Marc records
module Blacklight::Document::ChicagoNotesBibliography
  def self.extended(document)
    Blacklight::Document::ChicagoNotesBibliography.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:chicago_notes_bibliography, 'text/html')
  end

  def export_as_chicago_notes_bibliography
    cp = CiteProc::Processor.new style: 'chicago-note-bibliography', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end
end
