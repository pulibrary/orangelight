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
    cp = CiteProc::Processor.new style: 'modern-language-association', format: 'html'
    item = CiteProc::Item.new(properties)
    cp.import(item)
    cp.render(:bibliography, id:).first
  end
end
