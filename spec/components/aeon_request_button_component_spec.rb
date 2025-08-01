# frozen_string_literal: true

require "rails_helper"

RSpec.describe AeonRequestButtonComponent, type: :component do
  before do
    stub_holding_locations
  end
  let(:holding) do
    { "22740186070006421" => { "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421", "barcode" => "24680" }] } }
  end
  let(:document) do
    SolrDocument.new({ id: '1234', holdings_1display: holding.to_json })
  end
  subject { render_inline(described_class.new(document:)) }
  it "renders a link with the appropriate classes" do
    expect(subject.css('a').attribute('class').to_s).to eq('request btn btn-sm btn-primary')
  end
  it 'renders the typical request text' do
    expect(subject.css('a').text).to eq('Reading Room Request')
  end
  it 'includes aeon=false in the link url' do
    expect(subject.css('a').attribute('href').text).to include('https://princeton.aeon.atlas-sys.com/logon?Action=10&Form=30')
  end
end
