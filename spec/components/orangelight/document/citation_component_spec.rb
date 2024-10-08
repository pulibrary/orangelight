# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::Document::CitationComponent, type: :component, citation: true do
  let(:document) { SolrDocument.new(properties) }
  let(:properties) do
    {
      id: 'SCSB-2635660',
      author_citation_display: ["Saer, Juan José"]
    }
  end
  let(:component) { described_class.new(document:) }

  it 'can be rendered' do
    expect(render_inline(component).to_s).to include('Saer')
  end
end
