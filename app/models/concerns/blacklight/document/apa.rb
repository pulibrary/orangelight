# frozen_string_literal: true

# Creates an html APA citation for non-Marc records
module Blacklight::Document::Apa
  def self.extended(document)
    Blacklight::Document::Apa.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:apa, 'text/html')
  end

  def export_as_apa
    return export_as_apa_citation_txt if alma?

    cp = CiteProc::Processor.new style: 'apa', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end
end
