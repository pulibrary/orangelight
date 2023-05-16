# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhysicalHoldingsMarkupBuilder do
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
  let(:location) { 'Firestone Library' }
  let(:call_number) { 'PS3539.A74Z93 2000' }
  let(:shelving_title) { ['Shelving title'] }
  let(:supplements) { ['Supplement note'] }
  let(:indexes) { ['Index note 1', 'Index note 2'] }
  let(:request_link) { '<a href="/requests/1232432">Request</a>' }
  let(:holding) do
    {
      holding_id => {
        location:,
        library: 'Firestone Library',
        location_code: 'f',
        call_number:,
        shelving_title:,
        supplements:,
        indexes:
      }.with_indifferent_access
    }
  end
  let(:document) { instance_double(SolrDocument) }
  let(:builder) { described_class.new(adapter) }

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

  describe '.holding_location_span' do
    let(:holding_location_span_markup) { builder.holding_location_span('test-location', 'test-holding-id') }

    it 'generates the markup for a holding location' do
      expect(holding_location_span_markup).to include '<span class="location-text"'
      expect(holding_location_span_markup).to include 'test-location'
      expect(holding_location_span_markup).to include 'data-holding-id="test-holding-id"'
    end
  end

  describe '.shelving_title' do
    let(:shelving_title_markup) { described_class.shelving_titles_list(holding.first[1]) }

    it 'generates the markup for a supplement note' do
      expect(shelving_title_markup).to include "<li>#{shelving_title[0]}</li>"
      expect(shelving_title_markup).to include '<ul class="shelving-title">'
    end
  end

  describe '.supplements_list' do
    let(:supplements_list_markup) { described_class.supplements_list(holding.first[1]) }

    it 'generates the markup for a supplement note' do
      expect(supplements_list_markup).to include "<li>#{supplements[0]}</li>"
      expect(supplements_list_markup).to include '<ul class="holding-supplements">'
    end
  end

  describe '.indexes_list' do
    let(:indexes_list_markup) { described_class.indexes_list(holding.first[1]) }

    it 'generates the markup for a index note' do
      expect(indexes_list_markup).to include "<li>#{indexes[0]}</li>"
      expect(indexes_list_markup).to include "<li>#{indexes[1]}</li>"
      expect(indexes_list_markup).to include '<ul class="holding-indexes">'
    end
  end

  describe '.multi_item_availability' do
    let(:bib_id) { '9092827' }
    let(:multi_item_availability_markup) { described_class.multi_item_availability(bib_id, holding_id) }

    it 'generates the markup to support loading multi-item availability' do
      expect(multi_item_availability_markup).to include "data-record-id=\"#{bib_id}\""
      expect(multi_item_availability_markup).to include "data-holding-id=\"#{holding_id}\""
      expect(multi_item_availability_markup).to include '<ul class="item-status"'
    end
  end

  describe '.holding_location' do
    let(:holding_location_markup) { builder.holding_location(holding.first[1], location, holding_id, call_number) }

    context 'with firestone_locator on' do
      before do
        allow(Flipflop).to receive(:firestone_locator?).and_return(true)
      end

      it 'includes a link with mapping details' do
        expect(holding_location_markup).to include '<td class="library-location"'
        expect(holding_location_markup).to include "href=\"/catalog/123456/stackmap?loc=f&amp;cn=#{call_number}\""
        expect(holding_location_markup).to include 'Firestone Library'
        expect(holding_location_markup).to include 'data-holding-id="3668455"'
        expect(holding_location_markup).to include "data-map-location=\"#{holding.first[1]['location_code']}"
      end
    end

    context 'with firestone_locator off' do
      before do
        allow(Flipflop).to receive(:firestone_locator?).and_return(false)
      end

      it 'includes a span with mapping details' do
        expect(holding_location_markup).to include '<td class="library-location"'
        expect(holding_location_markup).to include '<span class="location-text"'
        expect(holding_location_markup).to include 'Firestone Library'
        expect(holding_location_markup).to include 'data-holding-id="3668455"'
        expect(holding_location_markup).to include "data-map-location=\"#{holding.first[1]['location_code']}"
      end
    end
  end

  describe '.location_services_block' do
    let(:location_services_block_markup) { described_class.location_services_block(adapter, holding_id, location_rules, request_link, holding) }

    it 'generates the markup for the location services container' do
      expect(location_services_block_markup).to include '<td class="location-services service-conditional"'
      expect(location_services_block_markup).to include 'data-open="false"'
      expect(location_services_block_markup).to include 'data-requestable="true"'
      expect(location_services_block_markup).to include 'data-aeon="false"'
      expect(location_services_block_markup).to include 'data-holding-id="3668455"'
    end
  end

  describe '.request_placeholder' do
    let(:request_placeholder_markup) { builder.request_placeholder(adapter, holding_id, location_rules, holding) }

    it 'generates the markup for request links' do
      expect(request_placeholder_markup).to include '<td class="location-services service-conditional"'
      expect(request_placeholder_markup).to include 'data-open="false"'
      expect(request_placeholder_markup).to include 'data-requestable="true"'
      expect(request_placeholder_markup).to include 'data-aeon="false"'
      expect(request_placeholder_markup).to include 'data-holding-id="3668455"'
      expect(request_placeholder_markup).to include '<a '
      expect(request_placeholder_markup).to include 'title="View Options to Request copies from this Location"'
      expect(request_placeholder_markup).to include 'href="/requests/123456?aeon=false&amp;mfhd=3668455"'
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
        mock_solr_document
        allow(adapter).to receive(:document).and_return(document)
      end
      # this should be hitting the third condition, but does not seem to be
      it 'generates an aeon link including data from the host and constituent record' do
        expect(request_placeholder_markup).to include '<td class="location-services service-always-requestable"'
        expect(request_placeholder_markup).to include 'data-open="false"'
        expect(request_placeholder_markup).to include 'data-requestable="true"'
        expect(request_placeholder_markup).to include 'data-aeon="true"'
        expect(request_placeholder_markup).to include 'data-holding-id="numismatics"'
        expect(request_placeholder_markup).to include '<a '
        expect(request_placeholder_markup).to include 'title="Request to view in Reading Room"'
        expect(request_placeholder_markup).to include 'href="https://lib-aeon.princeton.edu/aeon/aeon.dll/OpenURL'
        expect(request_placeholder_markup).to include 'ItemNumber=host123'
      end
    end

    context "a supervised scsb item" do
      let(:holding_id) { '6670178' }
      let(:location_rules) do
        {
          "label": "Remote Storage",
          "code": "scsbnypl",
          "aeon_location": false,
          "recap_electronic_delivery_location": true,
          "open": false,
          "requestable": true,
          "always_requestable": false,
          "circulates": true,
          "remote_storage": "recap_rmt",
          "fulfillment_unit": nil,
          "url": "https://bibdata.princeton.edu/locations/holding_locations/scsbnypl.json",
          "library": {
            "label": "ReCAP",
            "code": "recap",
            "order": 0
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
        allow_any_instance_of(SolrDocument).to receive(:to_ctx).and_return(OpenURL::ContextObject.new)
        mock_solr_document
        allow(adapter).to receive(:document).and_return(document)
        allow(holding).to receive(:dig).and_return("SCSB-6593031")
      end

      it 'generates the request link for the host record' do
        expect(request_placeholder_markup).to include '<td class="location-services service-always-requestable"'
        expect(request_placeholder_markup).to include 'data-open="false"'
        expect(request_placeholder_markup).to include 'data-requestable="true"'
        expect(request_placeholder_markup).to include 'data-holding-id="6670178"'
        expect(request_placeholder_markup).to include '<a '
        expect(request_placeholder_markup).to include 'title="Request to view in Reading Room"'
        # The general scsbnypl location is *not* an aeon location, but if the holding use_statement is "Supervised Use",
        # it goes through aeon.
        expect(request_placeholder_markup).to include 'data-aeon="false"'
        expect(request_placeholder_markup).to include 'href="/requests/SCSB-6593031?aeon=true"'
      end
    end

    context "a scsb item" do
      let(:holding_id) { '11198370' }
      let(:location_rules) do
        {
          "label": "Remote Storage",
          "code": "scsbhl",
          "aeon_location": false,
          "recap_electronic_delivery_location": true,
          "open": false,
          "requestable": true,
          "always_requestable": false,
          "circulates": true,
          "remote_storage": "recap_rmt",
          "fulfillment_unit": nil,
          "url": "https://bibdata.princeton.edu/locations/holding_locations/scsbhl.json",
          "library": {
            "label" => "ReCAP",
            "code" => "recap",
            "order" => 0
          },
          "holding_library": nil
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
        expect(request_placeholder_markup).to include '<td class="location-services service-always-requestable"'
        expect(request_placeholder_markup).to include 'data-open="false"'
        expect(request_placeholder_markup).to include 'data-requestable="true"'
        expect(request_placeholder_markup).to include 'data-aeon="false"'
        expect(request_placeholder_markup).to include 'data-holding-id="11198370"'
        expect(request_placeholder_markup).to include '<a '
        expect(request_placeholder_markup).to include 'title="View Options to Request copies from this Location"'
        expect(request_placeholder_markup).to include 'href="/requests/SCSB-10422725?aeon=false"'
      end
    end

    context "when there is a host" do
      let(:location_rules) do
        {
          "label": "Orlando F. Weber Collection of Economic History",
          "code": "rare$exw",
          "aeon_location": true,
          "recap_electronic_delivery_location": false,
          "open": false,
          "requestable": true,
          "always_requestable": true,
          "circulates": false,
          "remote_storage": "",
          "fulfillment_unit": "Closed",
          "library": {
            "label": "Special Collections",
            "code": "rare",
            "order": 0
          },
          "holding_library": nil,
          "hours_location": nil,
          "delivery_locations": []
        }
      end
      let(:holding_id) { "22692760320006421" }
      let(:holding) do
        {
          holding_id => {
            location: "Orlando F. Weber Collection of Economic History",
            library: 'Firestone Library',
            location_code: 'rare$exw',
            call_number:,
            shelving_title:,
            supplements:,
            indexes:,
            mms_id: "99125038613506421"
          }.with_indifferent_access
        }
      end
      before do
        mock_solr_document
        allow(adapter).to receive(:document).and_return(document)
        allow(holding).to receive(:dig).and_return("99125038613506421")
      end
      it 'generates an aeon link including data from the host and constituent record' do
        expect(request_placeholder_markup).to include '<td class="location-services service-always-requestable"'
        expect(request_placeholder_markup).to include 'data-open="false"'
        expect(request_placeholder_markup).to include 'data-requestable="true"'
        expect(request_placeholder_markup).to include 'data-aeon="true"'
        expect(request_placeholder_markup).to include 'data-holding-id="22692760320006421"'
        expect(request_placeholder_markup).to include '<a '
        expect(request_placeholder_markup).to include 'title="Request to view in Reading Room"'
        expect(request_placeholder_markup).to include 'ItemNumber=host123'
      end
    end
    context "when there is temporary location with a request button" do
      let(:location_rules) do
        {
          "label": "Term Loan Reserves",
          "code": "lewis$resterm",
          "aeon_location": false,
          "recap_electronic_delivery_location": false,
          "open": false,
          "requestable": true,
          "always_requestable": false,
          "circulates": true,
          "remote_storage": "",
          "fulfillment_unit": "General",
          "library": {
            "label": "Lewis Library",
            "code": "lewis",
            "order": 0
          },
          "holding_library": nil,
          "hours_location": nil,
          "delivery_locations": []
        }
      end
      let(:holding_id) { "lewis$resterm" }
      let(:holding) do
        {
          "location_code": "lewis$resterm",
          "current_location": "Term Loan Reserves",
          "current_library": "Lewis Library",
          "call_number": "QC173.454 .A48 2010",
          "call_number_browse": "QC173.454 .A48 2010",
          "items": [{ "holding_id": "22753114530006421",
                      "id": "23753114520006421",
                      "status_at_load": "0",
                      "barcode": "32101078273891",
                      "copy_number": "1" }]
        }.with_indifferent_access
      end
      before do
        allow(adapter).to receive(:doc_id).and_return('9960861053506421')
        allow(adapter).to receive(:document).and_return(document)
      end
      it 'generates the request link with mfhd the first items holding_id' do
        expect(request_placeholder_markup).to include '<td class="location-services service-conditional"'
        expect(request_placeholder_markup).to include 'data-open="false"'
        expect(request_placeholder_markup).to include 'data-requestable="true"'
        expect(request_placeholder_markup).to include 'data-aeon="false"'
        expect(request_placeholder_markup).to include 'data-holding-id="lewis$resterm"'
        expect(request_placeholder_markup).to include "Request"
        expect(request_placeholder_markup).to include 'href="/requests/9960861053506421?aeon=false&amp;mfhd=22753114530006421"'
      end
    end
  end

  describe '.show_request' do
    let(:css_class) { described_class.show_request(adapter, location, id) }
    let(:id) { '9990928273506421' }
    let(:location) do
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
      expect(css_class).to eq 'service-conditional'
    end

    context 'with a numismatics holding' do
      let(:id) { 'numismatics' }
      let(:location) do
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
          'holding_library': nil,
          'hours_location': nil
        }.with_indifferent_access
      end

      before do
        allow(adapter).to receive(:alma_holding?).and_return(false)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end

    context 'with a thesis holding' do
      let(:id) { 'thesis' }
      let(:location) do
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
          'holding_library': nil,
          'hours_location': nil
        }.with_indifferent_access
      end

      before do
        allow(adapter).to receive(:alma_holding?).and_return(false)
        allow(adapter).to receive(:pub_date).and_return(2010)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end

    context 'with a SCSB holding' do
      let(:id) { 'scsb' }
      let(:location) do
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
          'holding_library': nil,
          'hours_location': nil
        }.with_indifferent_access
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end

    context 'with an aeon holding' do
      let(:id) { 'aeon' }
      let(:location) do
        {
          'label': 'Sylvia Beach Collection',
          'code': 'beac',
          'aeon_location': true,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': false,
          'always_requestable': true,
          'circulates': false,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/beac.json',
          'library': {
            'label': 'Rare Books and Special Collections',
            'code': 'rare',
            'order': 2
          },
          'holding_library': nil,
          'hours_location': {
            'label': 'Firestone Library - Rare Books and Special Collections',
            'code': 'rbsc'
          }
        }.with_indifferent_access
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end
  end
  describe '.open_location?' do
    let(:loc) { { open: true } }

    it 'returns the location open attribute value' do
      expect(described_class.open_location?(loc)).to eq true
    end
    it 'returns false when nil location is passed to function' do
      expect(described_class.open_location?(nil)).to eq false
    end
  end

  describe '.holding_location' do
    before do
      stub_holding_locations
      allow(document).to receive(:to_s).and_return('99112325153506421')
      allow(adapter).to receive(:document).and_return(document)
      allow(adapter).to receive(:doc_id).and_return('99112325153506421')
      allow(adapter).to receive(:unavailable_holding?).and_return(false)
    end

    let(:location_rules) do
      {
        'label': 'Mendel Music Library: Reserve',
        'code': 'mendel$res',
        'aeon_location': false,
        'recap_electronic_delivery_location': false,
        'open': false,
        'requestable': true,
        'always_requestable': false,
        'circulates': true,
        'remote_storage': "",
        'url': 'https://bibdata-alma-staging.princeton.edu/locations/holding_locations/mendel$res',
        'library': {
          'label': 'Mendel Music Library',
          'code': 'mendel',
          'order': 0
        },
        'holding_library': nil,
        'hours_location': nil
      }.with_indifferent_access
    end

    let(:adapter) { instance_double(HoldingRequestsAdapter) }
    let(:holding_id) { '22270490550006421' }
    let(:location) { 'Mendel Music Library: Reserve' }
    let(:call_number) { 'CD- 2018-11-11' }
    let(:request_link) { '<a href="/requests/99112325153506421">Request</a>' }
    let(:holding) do
      {
        holding_id => {
          location:,
          library: 'Mendel Music Library',
          location_code: 'mendel$res',
          call_number:
        }.with_indifferent_access
      }
    end
    let(:document) { instance_double(SolrDocument) }
    let(:holding_location_markup) { builder.holding_location(holding.first[1], location, holding_id, call_number) }

    it 'generates the markup for the holding locations' do
      expect(holding_location_markup).to include '<td class="library-location"'
      expect(holding_location_markup).to include '<span class="location-text"'
      expect(holding_location_markup).to include 'Mendel Music Library: Reserve'
      expect(holding_location_markup).to include 'data-holding-id="22270490550006421"'
      expect(holding_location_markup).to include "data-map-location=\"#{holding.first[1]['location_code']}"
    end
  end

  describe 'Special collections location with suppressed button' do
    before do
      stub_holding_locations
      allow(document).to receive(:to_s).and_return('99125501031906421')
      allow(adapter).to receive(:document).and_return(document)
      allow(adapter).to receive(:doc_id).and_return('99125501031906421')
      allow(adapter).to receive(:unavailable_holding?).and_return(false)
      allow(adapter).to receive(:sc_location_with_suppressed_button?).with(holding).and_return(true)
    end
    let(:location_rules) do
      {
        "label": "Remote Storage (ReCAP): Manuscripts. Special Collections Use Only",
        "code": "rare$xmr",
        "aeon_location": false,
        "recap_electronic_delivery_location": false,
        "open": true,
        "requestable": false,
        "always_requestable": false,
        "circulates": true,
        "remote_storage": "recap_rmt",
        "fulfillment_unit": "Closed",
        "library": {
          "label": "Special Collections",
          "code": "rare",
          "order": 0
        },
        "holding_library": nil,
        "delivery_locations": []
      }.with_indifferent_access
    end

    let(:adapter) { instance_double(HoldingRequestsAdapter) }
    let(:builder) { described_class.new(adapter) }
    let(:holding_id) { '22939015790006421' }
    let(:location) { 'Remote Storage (ReCAP): Manuscripts. Special Collections Use Only' }
    let(:call_number) { '' }
    let(:holding) do
      {
        holding_id => {
          location:,
          library: 'Special Collections',
          location_code: 'rare$xmr',
          call_number:
        }.with_indifferent_access
      }
    end
    let(:document) { instance_double(SolrDocument) }
    let(:holding_location_markup) { builder.holding_location(holding.first[1], location, holding_id, call_number) }
    let(:css_class) { described_class.show_request(adapter, location_rules, holding_id) }

    it 'generates the markup for the holding locations' do
      expect(holding_location_markup).to include '<td class="library-location"'
      expect(holding_location_markup).to include '<span class="location-text"'
      expect(holding_location_markup).to include 'Remote Storage (ReCAP): Manuscripts. Special Collections Use Only'
      expect(holding_location_markup).to include 'data-holding-id="22939015790006421"'
      expect(holding_location_markup).to include "data-map-location=\"#{holding.first[1]['location_code']}"
      expect(holding_location_markup).to include "data-location-library=\"#{holding.first[1]['library']}"
      expect(holding_location_markup).to include "data-location-name=\"#{location}"
    end

    it 'generates a "service-conditional" class' do
      expect(css_class).to eq 'service-conditional'
    end
  end
end

def mock_solr_document
  allow_any_instance_of(SolrDocument).to receive(:to_ctx).and_return(OpenURL::ContextObject.new)
  allow(document).to receive(:[]).and_return('data')
  allow(document).to receive(:to_ctx).and_return(OpenURL::ContextObject.new)
  allow(document).to receive(:holdings_all_display).and_return({ 'host_id' => { 'items' => [{ 'barcode' => 'host123' }] } })
end
