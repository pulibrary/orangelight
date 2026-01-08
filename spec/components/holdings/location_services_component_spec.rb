# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Holdings::LocationServicesComponent, type: :component do
  let(:rendered) do
    render_inline described_class.new(adapter, holding_id, location_rules, holding)
  end

  let(:location_rules) do
    {
      'label': 'German Languages Theses',
      'code': 'sdt',
      'aeon_location': false,
      'recap_electronic_delivery_location': false,
      'open': false,
      'requestable': true,
      'always_requestable': false,
      'circulates': true,
      'url': 'https://bibdata.princeton.edu/locations/holding_locations/sdt.json',
      'library': {
        'label': 'Forrestal Annex',
        'code': 'annexa',
        'order': 3
      },
      'holding_library': nil,
      'hours_location': nil
    }.with_indifferent_access
  end
  let(:adapter) { instance_double(HoldingRequestsAdapter) }
  let(:holding_id) { '3668455' }
  let(:document) { SolrDocument.new({ id: '123456' }) }

  let(:holding) do
    {
      location: 'Firestone Library',
      library: 'Firestone Library',
      location_code: 'firestone$stacks',
      call_number: 'PS3539.A74Z93 2000',
      shelving_title: ['Shelving title'],
      supplements: ['Supplement note'],
      indexes: ['Index note 1', 'Index note 2']
    }.with_indifferent_access
  end

  before do
    stub_holding_locations
    allow(document).to receive(:to_s).and_return('123456')
    allow(adapter).to receive(:document).and_return(document)
    allow(adapter).to receive(:doc_id).and_return('123456')
    allow(adapter).to receive(:alma_holding?).and_return(true)
    allow(adapter).to receive(:doc_electronic_access).and_return('http://arks.princeton.edu/ark:/88435/dsp0141687h654': ['DataSpace', 'Citation only'])
    allow(adapter).to receive(:unavailable_holding?).and_return(false)
    allow(adapter).to receive(:sc_location_with_suppressed_button?).with(holding).and_return(false)
  end

  it 'generates the markup for the location services container' do
    expect(rendered.to_s).to include '<td class="location-services service-conditional"'
    expect(rendered.to_s).to include 'data-open="false"'
    expect(rendered.to_s).to include 'data-requestable="true"'
    expect(rendered.to_s).to include 'data-aeon="false"'
    expect(rendered.to_s).to include 'data-holding-id="3668455"'
  end

  it 'generates the markup for request links' do
    expect(rendered.to_s).to include '<td class="location-services service-conditional"'
    expect(rendered.to_s).to include 'data-open="false"'
    expect(rendered.to_s).to include 'data-requestable="true"'
    expect(rendered.to_s).to include 'data-aeon="false"'
    expect(rendered.to_s).to include 'data-holding-id="3668455"'
    expect(rendered.to_s).to include '<a '
    expect(rendered.to_s).not_to include 'title="View Options to Request copies from this Location"'
    expect(rendered.to_s).to include 'href="/requests/123456?aeon=false&amp;mfhd=3668455"'
  end

  context 'an aeon record with multiple items' do
    let(:location_rules) do
      {
        'aeon_location': true
      }
    end
    let(:holding) do
      {
        "items" => [
          { "barcode" => "123" },
          { "barcode" => "456" }
        ]
      }.with_indifferent_access
    end
    it 'links to the requests form' do
      expect(rendered.to_s).to include 'href="/requests/123456?aeon=true&amp;mfhd=3668455"'
    end
  end

  context "a numismatics item" do
    let(:holding_id) { "numismatics" }
    let(:location_rules) do
      {
        "label" => "Numismatics Collection",
        "code" => "rare$num",
        "aeon_location" => true,
        "recap_electronic_delivery_location" => false,
        "open" => false,
        "requestable" => true,
        "always_requestable" => true,
        "circulates" => false,
        "remote_storage" => "",
        "fulfillment_unit" => "Closed",
        "url" => "https://bibdata.princeton.edu/locations/holding_locations/rare$num.json",
        "library" => {
          "label" => "Special Collections",
          "code" => "rare",
          "order" => 0
        },
        "holding_library" => nil
      }.with_indifferent_access
    end
    let(:holding) do
      {
        "location" => "Special Collections - Numismatics Collection",
        "library" => "Special Collections",
        "location_code" => "rare$num",
        "call_number" => "Coin 3750",
        "call_number_browse" => "Coin 3750",
        "mms_id" => "coin-3750"
      }.with_indifferent_access
    end

    before do
      allow(adapter).to receive(:alma_holding?).and_return(false)
      allow(adapter).to receive(:document).and_return(document)
    end

    it 'generates an aeon link including data from the host and constituent record' do
      allow(document).to receive(:holdings_all_display).and_return({ 'host_id' => { 'items' => [{ 'barcode' => 'host123' }] } })
      expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
      expect(rendered.to_s).to include 'data-open="false"'
      expect(rendered.to_s).to include 'data-requestable="true"'
      expect(rendered.to_s).to include 'data-aeon="true"'
      expect(rendered.to_s).to include 'data-holding-id="numismatics"'
      expect(rendered.to_s).to include '<a '
      expect(rendered.to_s).not_to include 'title="Request to view in Reading Room"'
      expect(rendered.to_s).to include 'href="https://princeton.aeon.atlas-sys.com/logon?Action=10'
      expect(rendered.to_s).to include 'ItemNumber=host123'
    end
  end

  context "a supervised scsb item" do
    let(:holding_id) { '6670178' }
    let(:location_rules) do
      {
        'label': "Remote Storage",
        'code': "scsbnypl",
        'aeon_location': false,
        'recap_electronic_delivery_location': true,
        'open': false,
        'requestable': true,
        'always_requestable': false,
        'circulates': true,
        'remote_storage': "recap_rmt",
        'fulfillment_unit': nil,
        'url': "https://bibdata.princeton.edu/locations/holding_locations/scsbnypl.json",
        'library': {
          'label': "ReCAP",
          'code': "recap",
          'order': 0
        },
        "holding_library" => nil
      }.with_indifferent_access
    end
    let(:holding) do
      {
        "location_code" => "scsbnypl",
        "location" => "Remote Storage",
        "library" => "ReCAP",
        "call_number" => "SLP (Viola, O. Bibliografia italiana della pena di morte)",
        "call_number_browse" => "SLP (Viola, O. Bibliografia italiana della pena di morte)",
        "items" => [
          {
            "holding_id" => "6670178",
            "id" => "10842783",
            "status_at_load" => "Available",
            "barcode" => "33433115858387",
            "copy_number" => "1",
            "use_statement" => "Supervised Use",
            "storage_location" => "RECAP",
            "cgd" => "Shared",
            "collection_code" => "NA"
          }
        ],
        "mms_id" => "SCSB-6593031"
      }.with_indifferent_access
    end

    before do
      allow(adapter).to receive(:document).and_return(document)
    end

    it 'generates the request link for the host record' do
      expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
      expect(rendered.to_s).to include 'data-open="false"'
      expect(rendered.to_s).to include 'data-requestable="true"'
      expect(rendered.to_s).to include 'data-holding-id="6670178"'
      expect(rendered.to_s).to include '<a '
      expect(rendered.to_s).not_to include 'title="Request to view in Reading Room"'
      # The general scsbnypl location is *not* an aeon location, but if the holding use_statement is "Supervised Use",
      # it goes through aeon.
      expect(rendered.to_s).to include 'data-aeon="false"'
      expect(rendered.to_s).to include 'href="/requests/SCSB-6593031?aeon=true"'
    end
  end

  context "a scsb item" do
    let(:holding_id) { '11198370' }
    let(:location_rules) do
      {
        'label': "Remote Storage",
        'code': "scsbhl",
        'aeon_location': false,
        'recap_electronic_delivery_location': true,
        'open': false,
        'requestable': true,
        'always_requestable': false,
        'circulates': true,
        'remote_storage': "recap_rmt",
        'fulfillment_unit': nil,
        'url': "https://bibdata.princeton.edu/locations/holding_locations/scsbhl.json",
        'library': {
          "label" => "ReCAP",
          "code" => "recap",
          "order" => 0
        },
        'holding_library': nil
      }.with_indifferent_access
    end
    let(:holding) do
      {
        "location_code" => "scsbhl",
        "location" => "Remote Storage",
        "library" => "ReCAP",
        "call_number" => "KF8742 .E357 2007",
        "call_number_browse" => "KF8742 .E357 2007",
        "items" => [
          {
            "holding_id" => "11198370",
            "id" => "16923563",
            "status_at_load" => "Available",
            "barcode" => "32044070003017",
            "storage_location" => "HD",
            "cgd" => "Shared",
            "collection_code" => "HK"
          }
        ],
        "mms_id" => "SCSB-10422725"
      }.with_indifferent_access
    end

    before do
      allow(adapter).to receive(:document).and_return(document)
      allow(holding).to receive(:dig).and_return("SCSB-10422725")
    end

    it 'generates the request link for the host record' do
      expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
      expect(rendered.to_s).to include 'data-open="false"'
      expect(rendered.to_s).to include 'data-requestable="true"'
      expect(rendered.to_s).to include 'data-aeon="false"'
      expect(rendered.to_s).to include 'data-holding-id="11198370"'
      expect(rendered.to_s).to include '<a '
      expect(rendered.to_s).not_to include 'title="View Options to Request copies from this Location"'
      expect(rendered.to_s).to include 'href="/requests/SCSB-10422725?aeon=false"'
    end
  end

  context "when there is a host" do
    let(:location_rules) do
      {
        'label': "Orlando F. Weber Collection of Economic History",
        'code': "rare$exw",
        'aeon_location': true,
        'recap_electronic_delivery_location': false,
        'open': false,
        'requestable': true,
        'always_requestable': true,
        'circulates': false,
        'remote_storage': "",
        'fulfillment_unit': "Closed",
        'library': {
          'label': "Special Collections",
          'code': "rare",
          'order': 0
        },
        'holding_library': nil,
        'hours_location': nil,
        'delivery_locations': []
      }
    end
    let(:holding_id) { "22692760320006421" }
    let(:holding) do
      {
        holding_id => {
          location: "Orlando F. Weber Collection of Economic History",
          library: 'Firestone Library',
          location_code: 'rare$exw',
          call_number: 'PS3539.A74Z93 2000',
          shelving_title: ['Shelving title'],
          supplements: ['Supplement note'],
          indexes: ['Index note 1', 'Index note 2'],
          mms_id: "99125038613506421"
        }.with_indifferent_access
      }
    end
    before do
      allow(adapter).to receive(:document).and_return(document)
      allow(holding).to receive(:dig).and_return("99125038613506421")
    end
    it 'generates an aeon link including data from the host and constituent record' do
      allow(document).to receive(:holdings_all_display).and_return({ 'host_id' => { 'items' => [{ 'barcode' => 'host123' }] } })

      expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
      expect(rendered.to_s).to include 'data-open="false"'
      expect(rendered.to_s).to include 'data-requestable="true"'
      expect(rendered.to_s).to include 'data-aeon="true"'
      expect(rendered.to_s).to include 'data-holding-id="22692760320006421"'
      expect(rendered.to_s).to include '<a '
      expect(rendered.to_s).not_to include 'title="Request to view in Reading Room"'
      expect(rendered.to_s).to include 'ItemNumber=host123'
    end
  end
  context "when there is temporary location with a request button" do
    let(:location_rules) do
      {
        'label': "Term Loan Reserves",
        'code': "lewis$resterm",
        'aeon_location': false,
        'recap_electronic_delivery_location': false,
        'open': false,
        'requestable': true,
        'always_requestable': false,
        'circulates': true,
        'remote_storage': "",
        'fulfillment_unit': "General",
        'library': {
          'label': "Lewis Library",
          'code': "lewis",
          'order': 0
        },
        'holding_library': nil,
        'hours_location': nil,
        'delivery_locations': []
      }
    end
    let(:holding_id) { "lewis$resterm" }
    let(:holding) do
      {
        'location_code': "lewis$resterm",
        'current_location': "Term Loan Reserves",
        'current_library': "Lewis Library",
        'call_number': "QC173.454 .A48 2010",
        'call_number_browse': "QC173.454 .A48 2010",
        'items': [{ 'holding_id': "22753114530006421",
                    'id': "23753114520006421",
                    'status_at_load': "0",
                    'barcode': "32101078273891",
                    'copy_number': "1" }]
      }.with_indifferent_access
    end
    before do
      allow(adapter).to receive(:doc_id).and_return('9960861053506421')
      allow(adapter).to receive(:document).and_return(document)
    end
    it 'generates the request link with mfhd the first items holding_id' do
      expect(rendered.to_s).to include '<td class="location-services service-conditional"'
      expect(rendered.to_s).to include 'data-open="false"'
      expect(rendered.to_s).to include 'data-requestable="true"'
      expect(rendered.to_s).to include 'data-aeon="false"'
      expect(rendered.to_s).to include 'data-holding-id="lewis$resterm"'
      expect(rendered.to_s).to include "Request"
      expect(rendered.to_s).to include 'href="/requests/9960861053506421?aeon=false&amp;mfhd=22753114530006421"'
    end
  end
  context "describe Request and Reading room button" do
    describe 'when the location is Firestone stacks' do
      let(:holding_id) { '221067105550006421' }
      let(:location_rules) do
        {
          'label': "Stacks",
          'code': "firestone$stacks",
          'aeon_location': false,
          'recap_electronic_delivery_location': false,
          'open': true,
          'requestable': true,
          'always_requestable': false,
          'circulates': true,
          'remote_storage': "",
          'fulfillment_unit': "General",
          'url': "https://bibdata.princeton.edu/locations/holding_locations/firestone$stacks.json",
          'library': { 'label': "Firestone Library", 'code': "firestone", 'order': 0 },
          'holding_library': nil
        }
      end
      let(:holding) do
        {
          'location_code': "firestone$stacks",
          'location': "Stacks",
          'library': "Firestone Library",
          'call_number': "NE1321.5 .B25313 2025",
          'call_number_browse': "NE1321.5 .B25313 2025",
          'items': [{ 'holding_id': "221067105550006421",
                      'id': "231067105540006421",
                      'status_at_load': "0" }],
          'mms_id': "99125410673606421"
        }.with_indifferent_access
      end
      before do
        allow(adapter).to receive(:document).and_return(document)
      end
      context 'when FlipFlop feature hide_marquand_non_rare_request_button is on' do
        before do
          allow(Flipflop).to receive(:hide_marquand_non_rare_request_button?).and_return(true)
        end

        it 'renders a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-conditional"'
          expect(rendered.to_s).to include "Request"
        end
      end
      context 'when FlipFlop feature hide_marquand_non_rare_request_button is off' do
        before do
          allow(Flipflop).to receive(:hide_marquand_non_rare_request_button?).and_return(false)
        end

        it 'renders a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-conditional"'
          expect(rendered.to_s).to include "Request"
        end
      end
    end

    describe 'when the location is Marquand Special Collections' do
      let(:holding_id) { '221067105550006421' }
      let(:location_rules) do
        {
          'label': "Remote Storage (ReCAP): Marquand Library Use Only Rare Books",
          'code': "marquand$pz",
          'aeon_location': true,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': true,
          'always_requestable': true,
          'circulates': false,
          'remote_storage': "recap_rmt",
          'fulfillment_unit': "Closed",
          'url': "https://bibdata.princeton.edu/locations/holding_locations/marquand$pz.json",
          'library': { 'label': "Marquand Library", 'code': "marquand", 'order': 0 },
          'holding_library': { 'label': "Marquand Library", 'code': "marquand", 'order': 0 }
        }
      end
      let(:holding) do
        {
          'location_code': "marquand$pz",
          'location': "Remote Storage (ReCAP): Marquand Library Use Only Rare Books",
          'library': "Marquand Library",
          'call_number': "NE1321.5 .B25313 2025",
          'call_number_browse': "NE1321.5 .B25313 2025",
          'items': [{ 'holding_id': "221067105550006421",
                      'id': "231067105540006421",
                      'status_at_load': "0" }],
          'mms_id': "99131494087106421"
        }.with_indifferent_access
      end
      before do
        allow(adapter).to receive(:document).and_return(document)
      end
      context 'when FlipFlop feature hide_marquand_special_collections_request_button is on' do
        before do
          allow(Flipflop).to receive(:hide_marquand_special_collections_request_button?).and_return(true)
        end

        it 'does not render a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
          expect(rendered.to_s).not_to include "Reading Room Request"
        end
      end
      context 'when FlipFlop feature hide_marquand_special_collections_request_button is off' do
        before do
          allow(Flipflop).to receive(:hide_marquand_special_collections_request_button?).and_return(false)
        end

        it 'renders a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-always-requestable"'
          expect(rendered.to_s).to include "Reading Room Request"
        end
      end
    end

    describe 'when the location is Marquand non rare' do
      let(:holding_id) { '22729708660006421' }
      let(:location_rules) do
        { 'label': "Tang Reading Room Remote Storage: Marquand Use Only",
          'code': "marquand$fesrf",
          'aeon_location': false,
          'recap_electronic_delivery_location': false, 'open': false,
          'requestable': true,
          'always_requestable': true,
          'circulates': false,
          'remote_storage': "", 'fulfillment_unit': "Closed",
          'url': "https://bibdata.princeton.edu/locations/holding_locations/marquand$fesrf.json",
          'library': { 'label': "Marquand Library", 'code': "marquand", 'order': 0 },
          'holding_library': nil }
      end
      let(:holding) do
        { 'location_code': "marquand$fesrf",
          'location': "Tang Reading Room Remote Storage: Marquand Use Only",
          'library': "Marquand Library",
          'call_number': "ND1042 .C485 2013q Oversize",
          'call_number_browse': "ND1042 .C485 2013q Oversize", 'sub_location': ["Oversize"],
          'items': [{ 'holding_id': "22729708660006421", 'description': "vol.6",
                      'id': "23729708570006421", 'status_at_load': "0",
                      'barcode': "32101108680719", 'copy_number': "0" }],
          'location_has': ["Vol. 1-v. 6"],
          'supplements': [nil], 'indexes': [nil],
          'mms_id': "9975702033506421" }.with_indifferent_access
      end
      before do
        allow(adapter).to receive(:document).and_return(document)
      end
      context 'when FlipFlop feature hide_marquand_non_rare_request_button is on' do
        before do
          allow(Flipflop).to receive(:hide_marquand_non_rare_request_button?).and_return(true)
        end

        it 'does not render a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-conditional"'
          expect(rendered.to_s).not_to include "Request"
        end
      end
      context 'when FlipFlop feature hide_marquand_non_rare_request_button is off' do
        before do
          allow(Flipflop).to receive(:hide_marquand_non_rare_request_button?).and_return(false)
        end

        it 'renders a request button' do
          expect(rendered.to_s).to include '<td class="location-services service-conditional"'
          expect(rendered.to_s).to include "Request"
        end
      end
    end
  end

  describe 'td css classes' do
    let(:css_class) { rendered.css('td').attribute('class').value }
    let(:holding_id) { '9990928273506421' }
    let(:location_rules) do
      {
        'label': 'African American Studies Reading Room (AAS). B-7-B',
        'code': 'firestone$aas',
        'aeon_location': false,
        'recap_electronic_delivery_location': false,
        'open': true,
        'requestable': true,
        'always_requestable': false,
        'circulates': false,
        'url': 'https://bibdata.princeton.edu/locations/holding_locations/firestone$aas.json',
        'library': {
          'label': 'Firestone Library',
          'code': 'firestone',
          'order': 0
        },
        'holding_library': nil
      }
    end

    it 'generates a "service-conditional" class' do
      expect(css_class).to include 'service-conditional'
    end

    context 'with a numismatics holding' do
      let(:holding_id) { 'numismatics' }
      let(:location_rules) do
        {
          'label': 'Numismatics Collection',
          'code': 'rare$num',
          'aeon_location': true,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': true,
          'always_requestable': true,
          'circulates': false,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/rare$num.json',
          'library': {
            'label': 'Special Collections ',
            'code': 'rare',
            'order': 2
          },
          'holding_library': nil
        }.with_indifferent_access
      end

      before do
        allow(adapter).to receive(:alma_holding?).and_return(false)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to include 'service-always-requestable'
      end
    end

    context 'with a thesis holding' do
      let(:holding_id) { 'thesis' }
      let(:location_rules) do
        {
          'label': 'German Theses',
          'code': 'annex$sdt',
          'aeon_location': false,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': true,
          'always_requestable': false,
          'circulates': true,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/annex$sdt.json',
          'library': {
            'label': 'Forrestal Annex',
            'code': 'annex',
            'order': 0
          },
          'holding_library': nil
        }.with_indifferent_access
      end

      before do
        allow(adapter).to receive(:alma_holding?).and_return(false)
        allow(adapter).to receive(:pub_date).and_return(2010)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to include 'service-always-requestable'
      end
    end

    context 'with a SCSB holding' do
      let(:holding_id) { 'scsb' }
      let(:location_rules) do
        {
          'label': '',
          'code': 'scsbcul',
          'aeon_location': false,
          'recap_electronic_delivery_location': true,
          'open': false,
          'requestable': true,
          'always_requestable': false,
          'circulates': true,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/scsbcul.json',
          'library': {
            'label': 'ReCAP',
            'code': 'recap',
            'order': 3
          },
          'holding_library': nil
        }.with_indifferent_access
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to include 'service-always-requestable'
      end
    end

    context 'with an aeon holding' do
      let(:holding_id) { 'aeon' }
      let(:location_rules) do
        {
          'label': 'Sylvia Beach Collection',
          'code': 'rare$beac',
          'aeon_location': true,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': false,
          'always_requestable': true,
          'circulates': false,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/rare$beac.json',
          'library': {
            'label': 'Special Collections',
            'code': 'rare',
            'order': 2
          },
          'holding_library': nil
        }.with_indifferent_access
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to include 'service-always-requestable'
      end
    end
  end
end
