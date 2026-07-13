# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::OnlineHoldingsComponent, type: :component do
  it 'renders nothing if there are no links in the document' do
    document = SolrDocument.new({ id: '9912345678906421' })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.to_html).to eq ''
  end

  it 'renders an OnlineOptions vue component if there are multiple links in the document' do
    document = SolrDocument.new({ id: '9912345678906421', electronic_portfolio_s: ['{"title": "Link 1", "url": "http://example.com/1"}', '{"title": "Link 2", "url": "http://example.com/2"}'] })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('.online-holdings-list')).not_to be_empty
  end

  it 'does not consider the IIIF manifest to be a link' do
    document = SolrDocument.new({ id: '9912345678906421', electronic_access_1display: '{"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/dc6108vq57s":"https://figgy.princeton.edu/concern/scanned_resources/f72abd1a-e6d9-44ac-803d-c74ab97eb0ad/manifest"}}' })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.to_html).to eq ''
  end

  it 'does not render an online availability lux-text-style for items with finding aids' do
    document = SolrDocument.new({ id: '9912345678906421', electronic_access_1display: '{"http://arks.princeton.edu/ark:/88435/pz50gw142":["Princeton University Library Finding Aids","Search and Request"]}' })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('li span')).to be_empty
  end
end
