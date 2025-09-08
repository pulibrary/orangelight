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
        location:,
        library: 'Firestone Library',
        location_code: 'f',
        call_number:
      }
    }
  end
  let(:document) { instance_double(SolrDocument) }

  before do
    stub_holding_locations
    allow(document).to receive(:to_s).and_return('123456')
    allow(adapter).to receive(:document).and_return(document)
    allow(adapter).to receive(:doc_id).and_return('123456')
    allow(adapter).to receive(:alma_holding?).and_return(true)
    allow(adapter).to receive(:doc_electronic_access).and_return('http://gateway.proquest.com/url': ['gateway.proquest.com'], 'http://arks.princeton.edu/ark:/88435/dsp0141687h654': ['DataSpace', 'Citation only'])
  end

  describe '.electronic_access_link' do
    let(:link_markup) { described_class.electronic_access_link('http://arks.princeton.edu/ark:/88435/dsp01ft848s955', ['Full text']) }
    context 'when label - texts.first - for an external icon is an empty string' do
      it 'does not generate an icon for an empty string key and value' do
        # "electronic_access_1display": "{\"\":[\"\"], ... }"
        url = ''
        texts = ['']
        markup = described_class.electronic_access_link(url, texts)
        expect(markup).not_to include 'fa fa-external-link new-tab-icon-padding'
      end
    end

    it 'generates electronic access links for a catalog record' do
      parsed = Nokogiri::HTML link_markup

      link = parsed.at_css('a')
      expect(link['target']).to eq '_blank'
      expect(link['href']).to eq 'http://arks.princeton.edu/ark:/88435/dsp01ft848s955'
      expect(link.text).to eq 'Full text'
    end

    context 'with an open access record' do
      let(:link_markup) { described_class.electronic_access_link('http://hdl.handle.net/1802/27831', ['Open access']) }

      it 'generates electronic access links for a catalog record without a proxy' do
        parsed = Nokogiri::HTML link_markup

        link = parsed.at_css('a')
        expect(link['target']).to eq '_blank'
        expect(link['href']).to eq 'http://hdl.handle.net/1802/27831'
        expect(link.text).to eq 'Open access'
      end
    end

    context 'with a link to the IIIF Viewer' do
      let(:link_markup) { described_class.electronic_access_link('https://pulsearch.princeton.edu/catalog/4609321#view', ['arks.princeton.edu']) }

      it 'generates electronic access links for a catalog record which link to the IIIF Viewer' do
        parsed = Nokogiri::HTML link_markup

        link = parsed.at_css('a')
        expect(link['href']).to eq '/catalog/4609321#view'
        expect(link.text).to include 'Digital content'
      end
    end
    context "with a labeled link to the IIIF viewer" do
      let(:link_markup) { described_class.electronic_access_link('https://pulsearch.princeton.edu/catalog/4609321#view', ['Selected images']) }
      it 'generates electronic access links for a catalog record which link to the IIIF Viewer' do
        parsed = Nokogiri::HTML link_markup

        link = parsed.at_css('a')
        expect(link['href']).to eq '/catalog/4609321#view'
        expect(link.text).to include 'Selected images'
      end
    end
  end

  describe '.urlify' do
    let(:urlified_markup) { described_class.urlify(adapter) }

    it 'generates electronic access links for a catalog record' do
      expect(urlified_markup).to include 'href="https://login.ezproxy.princeton.edu/login?url=http://gateway.proquest.com/url">gateway.proquest.com<i class="fa fa-external-link new-tab-icon-padding" aria-label="opens in new tab" role="img"></i></a>'
      expect(urlified_markup).to include 'Citation only: <a target="_blank"'
      expect(urlified_markup).to include 'href="http://arks.princeton.edu/ark:/88435/dsp0141687h654"'
      expect(urlified_markup).to include 'DataSpace<i class="fa fa-external-link new-tab-icon-padding" aria-label="opens in new tab" role="img"></i></a>'
    end

    context '#urlify an Open access title' do
      let(:open_access_url) { 'http://hdl.handle.net/1802/27831' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(open_access_url => ['Open access'])
      end

      it 'does not have a proxy prefix added' do
        expect(urlified_markup).not_to include Requests.config['proxy_base']
      end
    end

    context '#urlify an non Open access title' do
      let(:electronic_access_url) { 'http://hdl.handle.net/1802/27831' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(electronic_access_url => ['I am a label'])
      end

      it 'does have a proxy prefix added' do
        expect(urlified_markup).to include Requests.config['proxy_base']
      end
    end

    context '.urlify with multiple, nested electronic access titles' do
      let(:electronic_access_url) { 'http://hdl.handle.net/1802/27831' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(electronic_access_url => [['I am a label'], ['I am another label']])
      end

      it 'flattens the set of electronic access titles' do
        expect(urlified_markup).to include Requests.config['proxy_base']
      end
    end

    context 'when a URL contains an encoded "|" character' do
      let(:gale_go_url) { 'http://go.galegroup.com/ps/i.do?id=GALE%257C9781440840869&v=2.1&u=prin77918&it=etoc&p=GVRL&sw=w' }

      before do
        allow(adapter).to receive(:doc_electronic_access).and_return(gale_go_url => ['go.galegroup.com'])
      end

      it 'ensures that the "|" character does not get encoded twice' do
        expect(urlified_markup).to include 'http://go.galegroup.com/ps/i.do?id=GALE%7C9781440840869'
      end
    end
  end

  describe 'electronic_portfolio_markup' do
    let(:portfolio_markup) { described_class.electronic_portfolio_markup(adapter) }

    context 'when a portfolio has a public note' do
      let(:portfolios) do
        [
          { 'desc' => 'Description',
            'title' => 'Title',
            'url' => 'https://princeton.edu/great-resource',
            'start' => '1980',
            'end' => '2015',
            'notes' => ['First note', 'Second note'] }
        ]
      end

      before do
        allow(adapter).to receive(:electronic_portfolios).and_return(portfolios)
        allow(adapter).to receive(:sibling_electronic_portfolios).and_return([])
      end

      it 'displays the public note properly' do
        parsed = Nokogiri::HTML.fragment(portfolio_markup)

        expect(parsed.children.count).to eq 1
        list_item = parsed.children.first
        expect(list_item.name).to eq 'li'
        expect(list_item['class']).to eq 'electronic-access lux'

        link = list_item.at_css 'a'
        expect(link['target']).to eq '_blank'
        expect(link['rel']).to eq 'noopener'
        expect(link['class']).to eq 'electronic-access-link'
        expect(link['href']).to eq 'https://princeton.edu/great-resource'
        expect(link.text).to eq '1980 - 2015: Title'

        show_more = list_item.at_css 'lux-show-more'
        expect(show_more.text).to eq 'Description'

        expect(list_item.text).to include '(First note, Second note)'
      end
    end
  end
end
