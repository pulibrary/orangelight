# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoldingRequestsAdapter do
  subject(:holdings) { described_class.new(document, bib_data_service) }

  let(:document) { instance_double(SolrDocument) }
  let(:bib_data_service) { class_double(Bibdata).as_stubbed_const(transfer_nested_constants: true) }

  describe '#doc_electronic_access' do
    it 'exposes electronic access links' do
      allow(document).to receive(:doc_electronic_access).and_return(JSON.parse('{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"]}'))
      expect(holdings.doc_electronic_access).to be_a Hash
      expect(holdings.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(holdings.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end
  end

  context 'Restrictions display' do
    let(:holdings_hash) do
      {
        '671799' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgc' => 'Open', 'collection_code' => 'NA' }] },
        '671798' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671798', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgc' => 'Open', 'collection_code' => 'NA' }] }
      }
    end
    let(:holdings_hash_empty_use_statement) do
      {
        '671799' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => '', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgc' => 'Open', 'collection_code' => 'NA' }] }
      }
    end

    context 'with repeared restrictions' do
      let(:document) { { 'holdings_1display' => holdings_hash.to_json } }

      it 'they appear only once' do
        expect(holdings.restrictions).to eq ['In Library Use']
      end
    end

    context 'with empty use_statement fields' do
      let(:document) { { 'holdings_1display' => holdings_hash_empty_use_statement.to_json } }

      it 'they are excluded' do
        expect(holdings.restrictions).to eq []
      end
    end
  end

  context 'with IIIF Manifest URLs indexed' do
    before do
      allow(document).to receive(:doc_electronic_access).and_return(JSON.parse('{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"],"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/7d278t10z":"https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest","http://arks.princeton.edu/ark:/88435/xp68kg247":"https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest"}}'))
    end

    it 'does not expose the manifest URLs' do
      expect(holdings.doc_electronic_access).to be_a Hash
      expect(holdings.doc_electronic_access).not_to have_key('iiif_manifests')
      expect(holdings.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(holdings.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end
  end

  describe '#iiif_manifests' do
    before do
      allow(document).to receive(:iiif_manifests).and_return(JSON.parse('{"http://arks.princeton.edu/ark:/88435/7d278t10z":"https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest","http://arks.princeton.edu/ark:/88435/xp68kg247":"https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest"}'))
    end

    it 'parses the manifest URLs' do
      expect(holdings.iiif_manifests).to be_a Hash
      expect(holdings.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/7d278t10z' => 'https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest'
      expect(holdings.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/xp68kg247' => 'https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest'
      expect(holdings.iiif_manifests).not_to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(holdings.iiif_manifests).not_to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end
  end
end
