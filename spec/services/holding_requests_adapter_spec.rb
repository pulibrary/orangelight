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
        '671799' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] },
        '671798' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671798', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] }
      }
    end
    let(:holdings_hash_empty_use_statement) do
      {
        '671799' => { 'location_code' => 'scsbnypl', 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => '', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] }
      }
    end

    context 'with repeared restrictions' do
      let(:document) { SolrDocument.new('holdings_1display' => holdings_hash.to_json) }

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

  describe '#doc_holdings_elf' do
    context 'When location codes are not available' do
      let(:holdings_hash) do
        {
          '671799' => { 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] },
          '671798' => { 'items' => [{ 'holding_id' => '671798', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] }
        }
      end
      let(:document) { { 'holdings_1display' => holdings_hash.to_json } }

      it 'returns an empty array' do
        expect(holdings.doc_holdings_elf).to be_empty
      end
    end
  end

  describe '#doc_holdings_physical' do
    context 'When location codes are not available' do
      let(:holdings_hash) do
        {
          '671799' => { 'items' => [{ 'holding_id' => '671799', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] },
          '671798' => { 'items' => [{ 'holding_id' => '671798', 'enumeration' => 'Oct., 1977- Mar., 1978', 'id' => '1118538', 'use_statement' => 'In Library Use', 'status_at_load' => 'Available', 'barcode' => '33433004579631', 'copy_number' => '1', 'cgd' => 'Open', 'collection_code' => 'NA' }] }
        }
      end
      let(:document) { { 'holdings_1display' => holdings_hash.to_json } }

      it 'returns an empty array' do
        expect(holdings.doc_holdings_physical).to be_empty
      end
    end

    context 'when parsing the holdings raises an exception' do
      let(:document) { { 'holdings_1display' => 'not json' } }

      it 'returns an empty array' do
        expect(holdings.doc_holdings_physical).to be_empty
      end
    end
  end

  describe '#grouped_physical_holdings' do
    it 'puts Firestone locations before branch locations' do
      allow(document).to receive(:holdings_all_display).and_return({
                                                                     '123' => { 'library' => 'Firestone', 'location' => 'Stacks', 'location_code' => 'firestone$stacks' },
                                                                     '456' => { 'library' => 'Special Collections', 'location' => 'Rare Books', 'location_code' => 'rare$ex' },
                                                                     '789' => { 'library' => 'Firestone', 'location' => 'Classics Collection', 'location_code' => 'firestone$class' },
                                                                     'abc' => { 'library' => 'Architecture Library', 'location' => 'Stacks', 'location_code' => 'arch$stacks' }
                                                                   })

      group_order = holdings.grouped_physical_holdings.map(&:group_name)
      expect(group_order).to eq [
        'Firestone - Classics Collection',
        'Firestone - Stacks',
        'Architecture Library - Stacks',
        'Special Collections - Rare Books'
      ]
    end

    it 'puts Annex locations after branch locations' do
      allow(document).to receive(:holdings_all_display).and_return({
                                                                     '123' => { 'library' => 'Annex', 'location' => 'Locked', 'location_code' => 'annex$locked' },
                                                                     'abc' => { 'library' => 'Architecture Library', 'location' => 'Stacks', 'location_code' => 'arch$stacks' }
                                                                   })

      group_order = holdings.grouped_physical_holdings.map(&:group_name)
      expect(group_order).to eq [
        'Architecture Library - Stacks',
        'Annex - Locked'
      ]
    end

    it 'puts Remote Storage locations after branch locations' do
      allow(document).to receive(:holdings_all_display).and_return({
                                                                     '123' => { 'library' => 'Special Collections', 'location' => 'Remote Storage (ReCAP): Historic Maps. Special Collections Use Only', 'location_code' => 'stokes$index' },
                                                                     'abc' => { 'library' => 'Stokes Library', 'location' => 'Indexes. Wallace Hall', 'location_code' => 'stokes$index' }
                                                                   })

      group_order = holdings.grouped_physical_holdings.map(&:group_name)
      expect(group_order).to eq [
        'Stokes Library - Indexes. Wallace Hall',
        'Special Collections - Remote Storage (ReCAP): Historic Maps. Special Collections Use Only'
      ]
    end
  end

  describe '#doc_id' do
    let(:document) { SolrDocument.new(id: 'SCSB-1234') }
    it 'can find the document id' do
      expect(holdings.doc_id).to eq 'SCSB-1234'
    end
  end
end
