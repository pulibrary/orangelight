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
        location: location,
        library: 'Firestone Library',
        location_code: 'f',
        call_number: call_number,
        shelving_title: shelving_title,
        supplements: supplements,
        indexes: indexes
      }.with_indifferent_access
    }
  end
  let(:document) { instance_double(SolrDocument) }

  before do
    stub_holding_locations
    allow(document).to receive(:to_s).and_return('123456')
    allow(adapter).to receive(:document).and_return(document)
    allow(adapter).to receive(:doc_id).and_return('123456')
    allow(adapter).to receive(:voyager_holding?).and_return(true)
    allow(adapter).to receive(:doc_electronic_access).and_return('http://arks.princeton.edu/ark:/88435/dsp0141687h654': ['DataSpace', 'Citation only'])
    allow(adapter).to receive(:umlaut_accessible?).and_return(true)
    allow(adapter).to receive(:unavailable_holding?).and_return(false)
  end

  describe '.request_label' do
    let(:request_label) { described_class.request_label(location_rules) }

    context 'for holdings within aeon locations' do
      let(:location_rules) do
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

      it 'generates a reading room request label' do
        expect(request_label).to eq 'Reading Room Request'
      end
    end

    it 'generates a generic request label' do
      expect(request_label).to eq 'Request Pick-up or Digitization'
    end
  end

  describe '.request_tooltip' do
    let(:request_tooltip) { described_class.request_tooltip(location_rules) }

    context 'for holdings within aeon locations' do
      let(:location_rules) do
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
        }
      end

      it 'generates a tooltip for requesting a view within the reading room' do
        expect(request_tooltip).to eq 'Request to view in Reading Room'
      end
    end

    it 'generates a tooltip for viewing options for requests' do
      expect(request_tooltip).to eq 'View Options to Request copies from this Location'
    end
  end

  describe '.holding_location_span' do
    let(:holding_location_span_markup) { described_class.holding_location_span('test-location', 'test-holding-id') }

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

    it 'generates the markup for a supplement note' do
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
    let(:holding_location_markup) { described_class.holding_location(adapter, holding.first[1], location, holding_id, call_number) }

    it 'generates the markup for the holding locations' do
      expect(holding_location_markup).to include '<td class="library-location"'
      expect(holding_location_markup).to include '<span class="location-text"'
      expect(holding_location_markup).to include 'Firestone Library'
      expect(holding_location_markup).to include 'data-holding-id="3668455"'
      expect(holding_location_markup).to include "href=\"/catalog/123456/stackmap?loc=f&amp;cn=#{call_number}\""
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
    let(:request_placeholder_markup) { described_class.request_placeholder(adapter, holding_id, location_rules, holding) }

    it 'generates the markup for request links' do
      expect(request_placeholder_markup).to include '<td class="location-services service-conditional"'
      expect(request_placeholder_markup).to include 'data-open="false"'
      expect(request_placeholder_markup).to include 'data-requestable="true"'
      expect(request_placeholder_markup).to include 'data-aeon="false"'
      expect(request_placeholder_markup).to include 'data-holding-id="3668455"'
      expect(request_placeholder_markup).to include '<a title="View Options to Request copies from this Location"'
      expect(request_placeholder_markup).to include 'href="/requests/123456?mfhd=3668455&amp;source=pulsearch"'
    end
  end

  describe '.show_request' do
    let(:css_class) { described_class.show_request(adapter, location, id) }
    let(:id) { '9092827' }
    let(:location) do
      {
        'label': 'African American Studies Reading Room (AAS). B-7-B',
        'code': 'aas',
        'aeon_location': false,
        'recap_electronic_delivery_location': false,
        'open': true,
        'requestable': false,
        'always_requestable': false,
        'circulates': false,
        'url': 'https://bibdata.princeton.edu/locations/holding_locations/aas.json',
        'library': {
          'label': 'Firestone Library',
          'code': 'firestone',
          'order': 1
        },
        'holding_library': nil,
        'hours_location': {
          'label': 'Firestone Library - Building and Circulation/Reserves Hours',
          'code': 'firestone'
        }
      }
    end

    context 'with non-Voyager holdings' do
      let(:id) { 'thesis' }
      let(:location) do
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

      before do
        allow(adapter).to receive(:voyager_holding?).and_return(false)
        allow(adapter).to receive(:pub_date).and_return(2010)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end

    context 'with non-Voyager holdings' do
      let(:id) { 'numismatics' }
      let(:location) do
        {
          'label': 'Numismatics Collection',
          'code': 'num',
          'aeon_location': true,
          'recap_electronic_delivery_location': false,
          'open': false,
          'requestable': true,
          'always_requestable': true,
          'circulates': false,
          'url': 'https://bibdata.princeton.edu/locations/holding_locations/num.json',
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
        allow(adapter).to receive(:voyager_holding?).and_return(false)
      end

      it 'generates a "service-always-requestable" class' do
        expect(css_class).to eq 'service-always-requestable'
      end
    end

    context 'with an aeon holding' do
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

    context 'with a SCSB holding' do
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

    it 'generates a "service-conditional" class' do
      expect(css_class).to eq 'service-conditional'
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
end
