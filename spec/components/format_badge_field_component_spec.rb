# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormatBadgeFieldComponent, type: :component do
  let(:rendered) do
    render_inline(described_class.new(field:))
  end
  let(:document) { SolrDocument.new 'id' => '9912345678906421', 'format' => ['Journal', 'Microform'] }
  let(:field_config) { Blacklight::Configuration::Field.new key: 'format', field: 'format', label: 'Format' }

  let(:field) do
    Blacklight::FieldPresenter.new vc_test_controller.view_context, document, field_config
  end

  it 'includes all formats' do
    expect(rendered.text).to include('Journal')
    expect(rendered.text).to include('Microform')
  end

  context 'when the record is electronic access' do
    let(:document) { SolrDocument.new 'id' => '9912345678906421', 'format' => ['Journal', 'Microform'], electronic_portfolio_s: ['{"title": "Link 1", "url": "http://example.com/1"}'] }
    it 'has a blue badge when deduplication feature is off' do
      allow(Flipflop).to receive(:deduplication).and_return(false)
      expect(rendered.css('lux-badge[color="blue"]')).to be_present
    end

    it 'has a purple badge when deduplication feature is on' do
      allow(Flipflop).to receive(:deduplication?).and_return(true)
      expect(rendered.css('lux-badge[color="purple"]')).to be_present
    end
  end
end
