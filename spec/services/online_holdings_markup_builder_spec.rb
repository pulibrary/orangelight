# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OnlineHoldingsMarkupBuilder do
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
  let(:holding) do
    {
      holding_id => {
        location: location,
        library: 'Firestone Library',
        location_code: 'f',
        call_number: call_number
      }
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
  end

  describe '.electronic_access_link' do
    let(:link_markup) { described_class.electronic_access_link('http://arks.princeton.edu/ark:/88435/dsp01ft848s955', ['Full text']) }

    it 'generates electronic access links for a catalog record' do
      expect(link_markup).to include '<a target="_blank"'
      expect(link_markup).to include 'href="https://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/ark:/88435/dsp01ft848s955"'
      expect(link_markup).to include 'Full text'
    end

    context 'with an open access record' do
      let(:link_markup) { described_class.electronic_access_link('http://hdl.handle.net/1802/27831', ['Open access']) }

      it 'generates electronic access links for a catalog record without a proxy' do
        expect(link_markup).to include '<a target="_blank"'
        expect(link_markup).to include 'href="http://hdl.handle.net/1802/27831"'
        expect(link_markup).to include 'Open access'
      end
    end
  end

  describe '.urlify' do
    let(:urlified_markup) { described_class.urlify(adapter) }

    it 'generates electronic access links for a catalog record' do
      expect(urlified_markup).to include 'Citation only: <a target="_blank"'
      expect(urlified_markup).to include 'href="https://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/ark:/88435/dsp0141687h654"'
      expect(urlified_markup).to include 'DataSpace</a>'
    end

    context '#urlify a marcit record' do
      let(:marcit_url) { 'http://getit.princeton.edu/resolve?url%5Fver=Z39.88-2004&ctx%5Fver=Z39.88-2004&ctx%5Fenc=info:ofi/enc:UTF-8&rfr%5Fid=info:sid/sfxit.com:opac%5F856&url%5Fctx%5Ffmt=info:ofi/fmt:kev:mtx:ctx&sfx.ignore%5Fdate%5Fthreshold=1&rft.object%5Fid=954925427238&svc%5Fval%5Ffmt=info:ofi/fmt:kev:mtx:sch%5Fsvc&' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(marcit_url => ['getit.princeton.edu', 'View Princeton online holdings'])
      end

      it 'is marked as full text record' do
        expect(urlified_markup).to include 'data-umlaut-full-text="true"'
      end

      it 'has a marcit context object' do
        expect(urlified_markup).to include 'data-url-marcit'
      end
    end

    context '#urlify an Open access title' do
      let(:open_access_url) { 'http://hdl.handle.net/1802/27831' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(open_access_url => ['Open access'])
      end

      it 'does not have a proxy prefix added' do
        expect(urlified_markup).not_to include ENV['proxy_base']
      end
    end

    context '#urlify an non Open access title' do
      let(:electronic_access_url) { 'http://hdl.handle.net/1802/27831' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(electronic_access_url => ['I am a label'])
      end

      it 'does have a proxy prefix added' do
        expect(urlified_markup).to include ENV['proxy_base']
      end
    end
  end
end
