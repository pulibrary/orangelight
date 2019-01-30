# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'umlaut_services spec' do
  let(:blacklight_config) do
    CatalogController.new.blacklight_config
  end

  before do
    stub_holding_locations
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe '#umlaut_services for a record with a marcit online option' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '1',
        'lccn_s' => ['2001522653'],
        'isbn_s' => ['9781400827824'],
        'oclc_s' => %w[19590730 301985443],
        'format' => ['Journal'],
        'location_code_s' => ['sa'],
        'electronic_access_1display' => "{\"https://getit.princeton.edu/resolve?url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info:ofi/enc:UTF-8&rfr_id=info:sid/sfxit.com:opac_856&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&sfx.ignore_date_threshold=1&rft.object_id=954925427238&svc_val_fmt=info:ofi/fmt:kev:mtx:sch_svc&\":[\"getit.princeton.edu\",\"View Princeton's online holdings\"]}",
        'holdings_1display' => '{"9592399":{"location":"Online - *ONLINE*","library":"Online","location_code":"elf1","call_number":"Electronic Resource","call_number_browse":"Electronic Resource"}}'
      }
    end

    it 'has all umlaut additional services' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'has full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).to have_selector '#full_text'
    end
  end

  context '#umlaut_services for a record with a non-marcit online option' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '2',
        'lccn_s' => ['2001522653'],
        'isbn_s' => ['9781400827824'],
        'oclc_s' => %w[19590730 301985443],
        'format' => ['Book'],
        'location_code_s' => ['sa'],
        'electronic_access_1display' => "{\"https://ebrary.com/121331313\":[\"ebrary.com\",\"View Princeton's online holdings\"]}",
        'holdings_1display' => '{"9592399":{"location":"Online - *ONLINE*","library":"Online","location_code":"elf1","call_number":"Electronic Resource","call_number_browse":"Electronic Resource"}}'
      }
    end

    it 'has all additional umlaut services' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'has full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).to have_selector '#full_text'
    end
  end

  context '#umlaut_services for a record without an existing online option' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '3',
        'lccn_s' => ['2001522653'],
        'isbn_s' => ['9781400827824'],
        'oclc_s' => %w[19590730 301985443],
        'format' => ['Book'],
        'location_code_s' => ['sa'],
        'holdings_1display' => '{"13395":{"location":"Forrestal Annex - Temporary","library":"Forrestal Annex","location_code":"anxafst","copy_number":"1","call_number":"PS3563.A3294 xT3","call_number_browse":"PS3563.A3294 xT3"}}'
      }
    end

    it 'has all possible umlaut additional services included' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'has full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).to have_selector '#full_text'
    end
  end

  context '#umlaut_services for a record without any standard numbers or eligible full-text formats' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '5',
        'format' => ['Book'],
        'location_code_s' => ['sa'],
        'holdings_1display' => '{"13395":{"location":"Forrestal Annex - Temporary","library":"Forrestal Annex","location_code":"anxafst","copy_number":"1","call_number":"PS3563.A3294 xT3","call_number_browse":"PS3563.A3294 xT3"}}'
      }
    end

    it 'has no umlaut additional services included' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).not_to have_selector '#highlighted_link'
      expect(rendered).not_to have_selector '#excerpts'
    end

    it 'does not have full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).not_to have_selector '#full_text'
    end
  end

  context 'has standard numbers and an ineligible full-text formats' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '5',
        'format' => ['Audio'],
        'oclc_s' => %w[19590730 301985443],
        'location_code_s' => ['sa'],
        'holdings_1display' => '{"13395":{"location":"Forrestal Annex - Temporary","library":"Forrestal Annex","location_code":"anxafst","copy_number":"1","call_number":"PS3563.A3294 xT3","call_number_browse":"PS3563.A3294 xT3"}}'
      }
    end

    it 'has highlighted links and excerpt umlaut blocks' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'does not have a full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).not_to have_selector '#full_text'
    end
  end

  context 'full-text eligible formats and standard numbers' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '5',
        'format' => %w[Manuscript Book],
        'oclc_s' => %w[19590730],
        'location_code_s' => ['sa'],
        'holdings_1display' => '{"13395":{"location":"Forrestal Annex - Temporary","library":"Forrestal Annex","location_code":"anxafst","copy_number":"1","call_number":"PS3563.A3294 xT3","call_number_browse":"PS3563.A3294 xT3"}}'
      }
    end

    it 'has highlighted links and excerpt umlaut blocks' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'has full-text service' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).to have_selector '#full_text'
    end
  end

  context '#umlaut_services for a record with a non-marcit online option and ineligible formats' do
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        'id' => '2',
        'oclc_s' => %w[19590730 301985443],
        'format' => ['Audio'],
        'location_code_s' => ['sa'],
        'electronic_access_1display' => "{\"https://ebrary.com/121331313\":[\"ebrary.com\",\"View Princeton's online holdings\"]}",
        'holdings_1display' => '{"9592399":{"location":"Online - *ONLINE*","library":"Online","location_code":"elf1","call_number":"Electronic Resource","call_number_browse":"Electronic Resource"}}'
      }
    end

    it 'has all umlaut highlighted link and excerpt services' do
      render partial: 'catalog/show_other_versions', locals: { document: document }
      expect(rendered).to have_selector '#highlighted_link'
      expect(rendered).to have_selector '#excerpts'
    end

    it 'does not have umlaut full-text options' do
      render partial: 'catalog/show_availability', locals: { document: document }
      expect(rendered).not_to have_selector '#full_text'
    end
  end
end
