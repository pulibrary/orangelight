# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::AeonUrl do
  let(:holdings) do
    { "12345" => {
      "location" => "Special Collections - Numismatics Collection",
      "library" => "Special Collections",
      "location_code" => "rare$num",
      "call_number" => "Coin 3750",
      "sub_location" => ["Euro 20Q"],
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
  it 'uses the document id as the ReferenceNumber' do
    expect(subject).to include('ReferenceNumber=9999999')
  end
  it 'takes the CallNumber from holdings_1display' do
    expect(subject).to include('CallNumber=Coin+3750')
  end
  it 'takes the SubLocation from the holdings_1display' do
    expect(subject).to include('SubLocation=Euro+20Q')
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
  context 'when using the deprecated aeon base url' do
    before do
      allow(Flipflop).to receive(:deprecated_aeon_base?).and_return(true)
    end
    it 'begins with the aeon prefix' do
      expect(subject).to match(/^#{Requests::Config[:aeon_base_deprecated]}/)
    end
  end
  context 'when using the new aeon base url' do
    before do
      allow(Flipflop).to receive(:deprecated_aeon_base?).and_return(false)
    end
    it 'begins with the aeon prefix' do
      expect(subject).to match(/^#{Requests::Config[:aeon_base]}/)
    end
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
  context 'when the location is at a Marquand location' do
    let(:holdings) do
      { "12345" => {
        "location_code" => "marquand$pz",
        "call_number" => "Coin 3750",
        "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421" }]
      } }
    end
    it 'uses MARQ as the site' do
      expect(subject).to include('Site=MARQ')
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
  context 'when a specific holding is passed in' do
    subject do
      holding = { "22667098990006421" => { "location_code" => "rare$ctsn", "location" => "Cotsen Children's Library", "library" => "Special Collections", "call_number" => "153521 Pams / NR / Chinese / Box 41", "call_number_browse" => "153521 Pams / NR / Chinese / Box 41", "location_has" => ["Vol. 1: [no. 1]-[no. 4] ([Jan.] 2013 - [Oct.] 2013)", "Vol. 2: no. 1-6 (=Issue no. 5-10; Jan. 2014 - Nov. 2014)", "Vol. 3: no. 1-6 (=Issue no. 11-16; Jan. 2015 - Nov. 2015)", "Vol. 4: no. 1-6 (=Issue no. 17-22; Jan. 2016 - Nov. 2016)", "Vol. 5: no. 1-6 (=Issue no. 23-28; Jan. 2017 - Nov. 2017)", "Princeton copy 1"],
                                           "items" => [{ "holding_id" => "22667098990006421", "id" => "23667098920006421", "status_at_load" => "1", "enumeration" => "Vol. 4: no. 1 - 6", "barcode" => "32101091127959", "copy_number" => "1" }, { "holding_id" => "22667098990006421", "id" => "23667098930006421", "status_at_load" => "1", "enumeration" => "Vol. 5: no. 1-6", "barcode" => "32101094417795", "copy_number" => "1" }, { "holding_id" => "22667098990006421", "id" => "23667098940006421", "status_at_load" => "1", "enumeration" => "Vol. 3: no. 1 - 6", "barcode" => "32101071686446", "copy_number" => "1" },
                                                       { "holding_id" => "22667098990006421", "id" => "23667098950006421", "status_at_load" => "1", "enumeration" => "Vol. 2: no. 1 - 6", "barcode" => "32101071686438", "copy_number" => "1" }, { "holding_id" => "22667098990006421", "id" => "23667098970006421", "status_at_load" => "0", "enumeration" => "9", "barcode" => "ISSitm51830.290-princetondb" }, { "holding_id" => "22667098990006421", "id" => "23667098960006421", "status_at_load" => "1", "enumeration" => "Vol 1: no. 1 - 4", "barcode" => "32101071302192", "copy_number" => "1" }] } }
      described_class.new(document:, holding:).to_s
    end
    it('takes the call number from the holding') do
      expect(subject).to include('CallNumber=153521+Pams+%2F+NR+%2F+Chinese+%2F+Box+41')
    end
  end
  context 'when a specific item is passed in' do
    subject do
      item = Requests::Requestable::Item.new({ "barcode" => "32101071302192", "id" => "23667098960006421", "holding_id" => "22667098990006421", "copy_number" => "1", "status" => "Available", "status_label" => "Item in place", "status_source" => "base_status", "process_type" => nil, "on_reserve" => "N", "item_type" => "Closed", "pickup_location_id" => "rare", "pickup_location_code" => "rare", "location" => "rare$ctsn", "label" => "Special Collections - Cotsen Children's Library", "description" => "Vol 1: no. 1 - 4 Jan 2013 - Oct 2013", "enum_display" => "Vol 1: no. 1 - 4", "chron_display" => "Jan 2013 - Oct 2013", "in_temp_library" => false })
      described_class.new(document:, item:).to_s
    end
    it('takes the barcode from the item') do
      expect(subject).to include('ItemNumber=32101071302192')
    end
    it('takes enumeration from the item') do
      expect(subject).to include('rft.volume=Vol+1%3A+no.+1+-+4')
    end
  end
end
