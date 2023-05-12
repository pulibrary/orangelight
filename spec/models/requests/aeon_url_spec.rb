# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::AeonUrl do
  let(:holdings) do
    { "12345" => {
      "location" => "Special Collections - Numismatics Collection",
      "library" => "Special Collections",
      "location_code" => "rare$num",
      "call_number" => "Coin 3750",
      "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421", "barcode" => "24680" }]
    } }
  end
  let(:document) do
    SolrDocument.new({
                       id: '9999999',
                       holdings_1display: holdings.to_json.to_s
                     })
  end
  before do
    stub_holding_locations
  end
  subject { described_class.new(document:).to_s }
  it 'begins with the aeon prefix' do
    expect(subject).to match(/^#{Requests::Config[:aeon_base]}/)
  end
  it 'uses the document id as the ReferenceNumber' do
    expect(subject).to include('ReferenceNumber=9999999')
  end
  it 'takes the CallNumber from holdings_1display' do
    expect(subject).to include('CallNumber=Coin+3750')
  end
  it 'typically uses RBSC as the Site' do
    expect(subject).to include('Site=RBSC')
  end
  it 'takes the openurl iteminfo5 from the item id' do
    expect(subject).to include('rft.iteminfo5=23740186060006421')
  end
  it 'takes the ItemNumber from the barcode' do
    expect(subject).to include('ItemNumber=24680')
  end
  context 'when the location is at a Mudd location' do
    let(:holdings) do
      { "12345" => {
        "location_code" => "mudd$prnc",
        "call_number" => "Coin 3750",
        "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421" }]
      } }
    end
    it 'uses MUDD as the site' do
      expect(subject).to include('Site=MUDD')
    end
  end
  context 'when a thesis holding' do
    let(:holdings) do
      { "thesis": { "call_number": "AC102", "call_number_browse": "AC102", "dspace": true } }
    end
    it 'uses MUDD as the site' do
      expect(subject).to include('Site=MUDD')
    end
  end
  context 'when bib record is a constituent' do
    let(:document) { SolrDocument.new({ id: '1234', contained_in_s: ['9999'] }) }
    it 'takes its ItemNumber from the host record barcode' do
      allow(document).to receive(:doc_by_id) { { 'holdings_1display' => '{"1":{"items":[{"barcode":"33_host_barcode"}]}}' } }
      expect(subject).to include('ItemNumber=33_host_barcode')
    end
  end
end
