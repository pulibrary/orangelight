# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::OnlineHoldingsComponent, type: :component do
  it 'renders nothing if there are no links in the document' do
    document = SolrDocument.new
    rendered = render_inline(described_class.new(document:))
    expect(rendered.to_html).to eq ''
  end

  it 'renders a direct link to the online resource if there is 1 link in the document' do
    document = SolrDocument.new({ electronic_portfolio_s: ['{"title": "Link 1", "url": "http://example.com/1"}'] })

    rendered = render_inline(described_class.new(document:))

    expect(rendered.css('a').text).to eq('Link 1')
    expect(rendered.css('a').attribute('href').text).to eq('http://example.com/1')
  end

  it 'renders an OnlineOptions vue component if there are multiple links in the document' do
    document = SolrDocument.new({ electronic_portfolio_s: ['{"title": "Link 1", "url": "http://example.com/1"}', '{"title": "Link 2", "url": "http://example.com/2"}'] })
    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('.lux online-options')).not_to be_empty
  end
end