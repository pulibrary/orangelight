# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  include ApplicationHelper

  subject(:solr_document) { described_class.new(properties) }

  let(:properties) do
    {}
  end

  describe '#to_marc' do
    let(:bibid) { '6574987' }
    let(:properties) do
      {
        'id' => bibid
      }
    end
    let(:marc_xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'bibdata', "#{bibid}.xml")) }

    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
        status: 200,
        body: marc_xml
      )
    end

    it 'retrieves the MARC data from over the HTTP and constructs a MARC::Record object' do
      expect(solr_document.to_marc).to be_a MARC::Record
      expect(solr_document.to_marc.to_xml.to_s).to eq(marc_xml)
    end

    context 'when the remote MARC record cannot be retrieved' do
      before do
        stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
          status: 500,
          body: ''
        )
      end
      it 'returns nil' do
        expect(solr_document.to_marc).to be nil
      end
    end
  end

  describe '#export_as_marcxml' do
    let(:bibid) { '6574987' }
    let(:properties) do
      {
        'id' => bibid
      }
    end
    let(:marc_xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'bibdata', "#{bibid}.xml")) }

    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
        status: 200,
        body: marc_xml
      )
    end

    it 'generates the XML from the remote MARC record' do
      expect(solr_document.export_as_marcxml).to eq(marc_xml)
    end

    context 'when the remote MARC record cannot be retrieved' do
      before do
        stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
          status: 500,
          body: ''
        )
      end
      it 'returns an empty String' do
        expect(solr_document.export_as_marcxml).to eq('')
      end
    end
  end

  describe '#export_as_refworks_marc_txt' do
    let(:bibid) { '6574987' }
    let(:properties) do
      {
        'id' => bibid
      }
    end
    let(:marc_xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'bibdata', "#{bibid}.xml")) }
    let(:refworks_txt) do
      "LEADER 00468cam a22001455a 4500001    6574987\n005    20110919084640.0\n008    110602s2011    nju           000 0 eng  \n040    NjP |cNjP\n100 1  Velez, Carlos.\n245 10 Searching for a modern aesthetic : |bfrom furniture to design / |cCarlos Velez.\n260     |c2011\n300    139 p. : |bill. ; |c29 x 23 cm.\n500    Advisor(s): Spyridon Papapetros, Lucia Allais\n502    Thesis (Senior)--Princeton University, 2011.\n852 8   |06536318 |brcppw |hSen. Th. 2011 Vel |xtr fr uesla\n959    2011-06-02 09:01:58 -0500\n"
    end

    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
        status: 200,
        body: marc_xml
      )
    end

    it 'generates the refworks record' do
      expect(solr_document.export_as_refworks_marc_txt).to eq(refworks_txt)
    end

    context 'when the remote MARC record cannot be retrieved' do
      before do
        stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
          status: 500,
          body: ''
        )
      end
      it 'returns an empty String' do
        expect(solr_document.export_as_refworks_marc_txt).to eq('')
      end
    end
  end

  describe '#identifiers' do
    context 'with no identifiers' do
      it 'is a blank array' do
        expect(solr_document.identifiers).to eq []
      end
    end
    context 'with identifiers' do
      let(:properties) do
        {
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w[19590730 301985443]
        }
      end

      it 'has an identifier object each' do
        expect(solr_document.identifiers.length).to eq 3
      end
    end
  end

  describe '#identifier_data' do
    context 'with identifiers' do
      let(:properties) do
        {
          'lccn_s' => ['2001522653'],
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w[19590730 301985443]
        }
      end
      it 'returns a hash of identifiers for data embeds, excludes lccn' do
        expect(solr_document.identifier_data).to eq(
          isbn: [
            '9781400827824'
          ],
          oclc: %w[
            19590730
            301985443
          ]
        )
      end
    end
  end

  describe '#export_as_openurl_ctx_kev' do
    let(:properties) do
      {
        'id' => '123',
        'format' => ['Book']
      }
    end
    let(:format_string) { 'info:ofi/fmt:kev:mtx:book' }

    it 'returns an encoded string' do
      expect((solr_document.export_as_openurl_ctx_kev('book').is_a? String)).to be true
      expect(solr_document.export_as_openurl_ctx_kev('book')).to include("rft_val_fmt=#{CGI.escape(format_string)}")
    end
  end

  describe '#to_ctx' do
    context 'A book' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Book'],
          'title_citation_display' => ['citation title']
        }
      end

      it 'returns a ctx with a format book' do
        expect(solr_document.to_ctx(solr_document['format']).to_hash['rft.genre']).to eq('book')
      end

      it 'Does not have a rft.title param' do
        expect(solr_document.to_ctx(solr_document['format']).to_hash.key?('rft.title')).to be false
      end
    end

    context 'A Journal' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Journal'],
          'title_citation_display' => ['A journal title']
        }
      end

      it 'returns a ctx with a format serial' do
        expect(solr_document.to_ctx(solr_document['format']).to_hash['rft.genre']).to eq('serial')
      end

      it 'does not have a journal rft.atitle param' do
        expect(solr_document.to_ctx(solr_document['format']).to_hash.key?('rft.title')).to be false
      end
    end

    context 'Other formats' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Musical score']
        }
      end

      it 'returns a ctx with format unknown' do
        expect(solr_document.to_ctx(solr_document['format']).to_hash['rft.genre']).to eq('unknown')
      end
    end
  end

  describe '#standard_numbers?' do
    context 'With standard numbers' do
      let(:properties) do
        {
          'id' => '1213313',
          'lccn_s' => ['2001522653'],
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w[19590730 301985443]
        }
      end

      it 'returns true when one or more standard number keys are present' do
        expect(solr_document.standard_numbers?).to be true
      end
    end

    context 'Without standard numbers' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns false when no standard number keys are present' do
        expect(solr_document.standard_numbers?).to be false
      end
    end
  end

  describe 'alma_record?' do
    context 'A alma record' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns true with a alma record' do
        expect(solr_document.alma_record?).to be true
      end
    end

    context 'A non-alma record' do
      let(:properties) do
        {
          'id' => 'dsp1213313'
        }
      end

      it 'returns false when it did not originate from alma' do
        expect(solr_document.alma_record?).to be false
      end
    end
  end

  describe 'ark' do
    context 'there is no value' do
      it 'returns nil' do
        expect(solr_document.ark).to be_nil
      end
    end
    context 'when it has no ark in 1display' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'test' => 'one' }.to_json
        }
      end

      it 'returns nil' do
        expect(solr_document.ark).to be_nil
      end
    end
    context 'when it has an ark in 1display' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'http://arks.princeton.edu/ark:/88435/fj236339x' => 'one' }.to_json
        }
      end

      it 'returns the ark' do
        expect(solr_document.ark).to eq 'ark:/88435/fj236339x'
      end
    end
    context 'when it has multiple options only one an ark' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'one' => 'two', 'http://arks.princeton.edu/ark:/88435/fj236339x' => 'one' }.to_json
        }
      end

      it 'returns the ark' do
        expect(solr_document.ark).to eq 'ark:/88435/fj236339x'
      end
    end
  end

  describe '#export_formats' do
    context 'with a voyager record' do
      let(:properties) do
        {
          'id' => '8908514',
          'holdings_1display' => { '8908514' => '{}' }.to_json
        }
      end

      it 'includes voyager-only formats' do
        expect(solr_document.export_formats).to have_key :endnote
      end
    end

    context 'with a thesis record' do
      let(:properties) do
        {
          'id' => 'dsp01zk51vk08g',
          'holdings_1display' => { 'thesis' => '{}' }.to_json
        }
      end

      it 'does not include voyager-only formats' do
        expect(solr_document.export_formats).not_to have_key :endnote
      end
    end

    context 'with a SCSB record' do
      let(:properties) do
        {
          'id' => 'SCSB-6593031'
        }
      end

      it 'does not include voyager-only formats' do
        expect(solr_document.export_formats).not_to have_key :endnote
      end
    end
  end

  describe '#doc_electronic_access' do
    let(:properties) do
      {
        'electronic_access_1display' => '{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"]}'
      }
    end

    it 'exposes electronic access links' do
      expect(solr_document.doc_electronic_access).to be_a Hash
      expect(solr_document.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(solr_document.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end

    context 'with IIIF Manifest URLs indexed' do
      let(:properties) do
        {
          'electronic_access_1display' => '{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"],"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/7d278t10z":"https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest","http://arks.princeton.edu/ark:/88435/xp68kg247":"https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest"}}'
        }
      end
      it 'does not expose the manifest URLs' do
        expect(solr_document.doc_electronic_access).to be_a Hash
        expect(solr_document.doc_electronic_access).not_to have_key('iiif_manifests')
        expect(solr_document.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
        expect(solr_document.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
      end
    end
  end

  describe '#iiif_manifests' do
    let(:properties) do
      {
        'electronic_access_1display' => '{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"],"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/7d278t10z":"https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest","http://arks.princeton.edu/ark:/88435/xp68kg247":"https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest"}}'
      }
    end
    it 'parses the manifest URLs' do
      expect(solr_document.iiif_manifests).to be_a Hash
      expect(solr_document.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/7d278t10z' => 'https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest'
      expect(solr_document.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/xp68kg247' => 'https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest'
      expect(solr_document.iiif_manifests).not_to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(solr_document.iiif_manifests).not_to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end
  end

  describe '#related_bibs_iiif_manifest' do
    context "without related mms_id" do
      let(:properties) do
        {
          'id' => '9956597633506421'
        }
      end
      it 'returns an empty list' do
        expect(solr_document.related_bibs_iiif_manifest).to eq []
      end
    end
    context 'with one related mms_id' do
      let(:properties) do
        {
          'id' => '9956597633506421',
          'electronic_access_1display' => "{\"https://catalog.princeton.edu/catalog/9956630863506421#view\":[\"Index\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/zk51vm39g\":\"https://figgy.princeton.edu/concern/scanned_resources/10a91d1b-bba8-418a-9590-0718149fa0cd/manifest\"}}"
        }
      end
      it 'finds the related mms_id' do
        expect(solr_document.related_bibs_iiif_manifest).to eq ["9956630863506421"]
      end
    end
    context 'with one related Voyager mms_id' do
      let(:properties) do
        {
          'id' => '9956597633506421',
          'electronic_access_1display' => "{\"https://catalog.princeton.edu/catalog/5663086#view\":[\"Index\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/zk51vm39g\":\"https://figgy.princeton.edu/concern/scanned_resources/10a91d1b-bba8-418a-9590-0718149fa0cd/manifest\"}}"
        }
      end
      it 'finds the related Alma mms_id' do
        expect(solr_document.related_bibs_iiif_manifest).to eq ["9956630863506421"]
      end
    end
    context 'with a duplicated related mms_id' do
      let(:properties) do
        {
          'id' => '9970802153506421',
          'electronic_access_1display' => "{\"https://catalog.princeton.edu/catalog/7078205#view\":[\"Table of contents\"],\"https://catalog.princeton.edu/catalog/7078205#view_1\":[\"Page images\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/8623j234x\":\"https://figgy.princeton.edu/concern/scanned_resources/0f282e1e-58ce-47f0-b647-edca822ac532/manifest\",\"http://arks.princeton.edu/ark:/88435/np193b460\":\"https://figgy.princeton.edu/concern/scanned_resources/1a768d6d-4b82-45fb-85cd-50cba358b4d9/manifest\"}}"
        }
      end
      it 'finds the related mms_id' do
        expect(solr_document.related_bibs_iiif_manifest).to eq ["9970782053506421"]
      end
    end
    context 'with one related mms_id that points to the same bib' do
      let(:properties) do
        {
          'id' => '9956597633506421',
          'electronic_access_1display' => "{\"https://catalog.princeton.edu/catalog/9956597633506421#view\":[\"Index\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/zk51vm39g\":\"https://figgy.princeton.edu/concern/scanned_resources/10a91d1b-bba8-418a-9590-0718149fa0cd/manifest\"}}"
        }
      end
      it 'returns an empty list' do
        expect(solr_document.related_bibs_iiif_manifest).to eq []
      end
    end
    context 'with a link that does not point to catalog.princeton.edu' do
      let(:properties) do
        {
          'id' => '9956597633506421',
          'electronic_access_1display' => "{\"https://blahblah.princeton.edu/catalog/9956597633506421#view\":[\"Index\"],\"iiif_manifest_paths\":{\"http://arks.princeton.edu/ark:/88435/zk51vm39g\":\"https://figgy.princeton.edu/concern/scanned_resources/10a91d1b-bba8-418a-9590-0718149fa0cd/manifest\"}}"
        }
      end
      it 'returns an empty list' do
        expect(solr_document.related_bibs_iiif_manifest).to eq []
      end
    end
  end

  describe '#holdings_all_display' do
    let(:host_holdings_99124977073506421) { "{\"22747139640006421\":{\"location_code\":\"rare$gax\",\"location\":\"Graphic Arts Collection\",\"library\":\"Special Collections\",\"call_number\":\"2006-1398N\",\"call_number_browse\":\"2006-1398N\",\"items\":[{\"holding_id\":\"22747139640006421\",\"id\":\"23747139620006421\",\"status_at_load\":\"1\",\"barcode\":\"32101054083488\",\"copy_number\":\"1\"}]}}" }
    let(:constituent_holdings_9923427953506421) { "{\"22509251160006421\":{\"location_code\":\"rare$ex\",\"location\":\"Rare Books\",\"library\":\"Special Collections\",\"call_number\":\"HJ5118 .H4 1733\",\"call_number_browse\":\"HJ5118 .H4 1733\"}}" }
    let(:host_holdings_99125038613506421) { "{\"22692760320006421\":{\"location_code\":\"rare$exw\",\"location\":\"Orlando F. Weber Collection of Economic History\",\"library\":\"Special Collections\",\"call_number\":\"HJ5118 .Z99 v.1\",\"call_number_browse\":\"HJ5118 .Z99 v.1\",\"location_has\":[\"Princeton copy 1\"],\"items\":[{\"holding_id\":\"22692760320006421\",\"id\":\"23692760310006421\",\"status_at_load\":\"1\",\"barcode\":\"32101071303885\",\"copy_number\":\"1\"}]}}" }
    let(:host_holdings_99125026373506421) { "{\"22541176420006421\":{\"location_code\":\"rare$ex\",\"location\":\"Rare Books\",\"library\":\"Special Collections\",\"call_number\":\"Nelson 362030\",\"call_number_browse\":\"Nelson 362030\",\"items\":[{\"holding_id\":\"22541176420006421\",\"id\":\"23541176410006421\",\"status_at_load\":\"1\",\"barcode\":\"32101070784895\",\"copy_number\":\"1\"}]}}" }
    let(:combined_holdings) do
      JSON.parse(constituent_holdings_9923427953506421).merge(JSON.parse(host_holdings_99125038613506421)).merge(JSON.parse(host_holdings_99125026373506421))
    end

    it 'returns the original holdings if the record is not contained' do
      solr_document = described_class.new(id: "99124977073506421", holdings_1display: host_holdings_99124977073506421)
      expect(solr_document.holdings_all_display).to eq JSON.parse(host_holdings_99124977073506421)
    end

    it 'returns the holdings from the host record if the record is contained and has no holdings' do
      solr_document = described_class.new(id: "9947055653506421", "contained_in_s": ["99124977073506421"])
      expect(solr_document.holdings_all_display).to eq JSON.parse(host_holdings_99124977073506421)
    end

    it 'returns the combined holdings if the record is contained and has its own holdings' do
      solr_document = described_class.new(id: "9923427953506421", "contained_in_s": ["99125038613506421", "99125026373506421"], holdings_1display: constituent_holdings_9923427953506421)
      expect(solr_document.holdings_all_display).to eq combined_holdings
    end
  end
end
