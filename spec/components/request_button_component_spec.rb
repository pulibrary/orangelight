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
  it 'renders the typical title tooltip' do
    expect(subject.css('a').attribute('title').text).to eq('View Options to Request copies from this Location')
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
    it 'renders the aeon title tooltip' do
      expect(subject.css('a').attribute('title').text).to eq('Request to view in Reading Room')
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
end
