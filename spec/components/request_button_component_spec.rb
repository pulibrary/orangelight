# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestButtonComponent, type: :component do
  let(:location) do
    { aeon_location: false }
  end
  subject { render_inline(described_class.new(location:, doc_id: '123', holding_id: '456')) }
  it "renders a link with the appropriate classes" do
    expect(subject.css('a').attribute('class').to_s).to eq('request btn btn-xs btn-primary')
  end
  it 'does not render a tooltip' do
    expect(subject.css('a').attribute('title')).to be_falsey
  end
  it 'renders the typical request text' do
    expect(subject.css('a').text).to eq('Request')
  end
  it 'includes aeon=false in the link url' do
    expect(subject.css('a').attribute('href').text).to eq('/requests/123?aeon=false&mfhd=456')
  end

  context 'when at an aeon location' do
    let(:location) do
      { aeon_location: true }
    end
    it 'renders the aeon request text' do
      expect(subject.css('a').text).to eq('Reading Room Request')
    end
    it 'does not render a tooltip' do
      expect(subject.css('a').attribute('title')).to be_falsey
    end
    it 'includes aeon=true in the link url' do
      expect(subject.css('a').attribute('href').text).to eq('/requests/123?aeon=true&mfhd=456')
    end
  end

  context 'when no holding_id' do
    subject { render_inline(described_class.new(location:, doc_id: '123')) }
    it 'does not include mfhd param in the link url' do
      expect(subject.css('a').attribute('href').text).to eq('/requests/123?aeon=false')
    end
  end

  context 'scsb supervised use' do
    let(:holding) do
      { 'items' => [{ 'use_statement' => 'Supervised Use' }] }
    end
    subject { render_inline(described_class.new(location:, doc_id: '123', holding_id: '456', holding:)) }
    it 'includes aeon=true in the link url' do
      expect(subject.css('a').attribute('href').text).to eq('/requests/123?aeon=true&mfhd=456')
    end
    context 'when Supervised use is not capitalized' do
      let(:holding) do
        JSON.parse('{"location_code":"scsbcul","location":"Remote Storage","library":"ReCAP","call_number":"NK3620 .S8 1939g","call_number_browse":"NK3620 .S8 1939g","items":[{"holding_id":"5766968","id":"8481021","status_at_load":"Available","barcode":"CU90571142","copy_number":"1","use_statement":"Supervised use","storage_location":"RECAP","cgd":"Shared","collection_code":"CU"}]}')
      end
      it 'includes aeon=true in the link url' do
        expect(subject.css('a').attribute('href').text).to eq('/requests/123?aeon=true&mfhd=456')
      end
    end
  end
end
