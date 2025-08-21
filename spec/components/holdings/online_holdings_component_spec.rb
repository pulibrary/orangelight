# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::OnlineHoldingsComponent, type: :component do
  it 'renders nothing if there are no links in the document' do
    document = SolrDocument.new
    rendered = render_inline(described_class.new(document:))
    expect(rendered.to_html).to eq ''
  end

  it 'renders an OnlineOptions vue component if there are multiple links in the document' do
    document = SolrDocument.new({ electronic_portfolio_s: ['{"title": "Link 1", "url": "http://example.com/1"}', '{"title": "Link 2", "url": "http://example.com/2"}'] })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('.online-holdings-list')).not_to be_empty
  end

  it 'Converts links to EZProxy links where appropriate' do
    document = SolrDocument.new({ electronic_access_1display: '{"http://gateway.proquest.com/long-path-etc":["Link 1","Other info:"]}' })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('online-options')[0].attributes['link-json'].value).to include("https://login.ezproxy.princeton.edu/login?url=http://gateway.proquest.com/long-path-etc")
  end

  it 'does not render an online availability lux-text-style for items with finding aids' do
    document = SolrDocument.new({ electronic_access_1display: '{"http://arks.princeton.edu/ark:/88435/pz50gw142":["Princeton University Library Finding Aids","Search and Request"]}' })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('li span')).to be_empty
  end
end
