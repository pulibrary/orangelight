# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  include ApplicationHelper

  subject { described_class.new(properties) }

  let(:properties) { {} }

  describe '#identifiers' do
    context 'with no identifiers' do
      it 'is a blank array' do
        expect(subject.identifiers).to eq []
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
        expect(subject.identifiers.length).to eq 3
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
        expect(subject.identifier_data).to eq(
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
      expect((subject.export_as_openurl_ctx_kev('book').is_a? String)).to be true
      expect(subject.export_as_openurl_ctx_kev('book')).to include("rft_val_fmt=#{CGI.escape(format_string)}")
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
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('book')
      end

      it 'Does not have a rft.title param' do
        expect(subject.to_ctx(subject['format']).to_hash.key?('rft.title')).to be false
        # ['rft.title']).to eq(subject['title_citation_display'].first)
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
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('serial')
      end

      it 'does not have a journal rft.atitle param' do
        expect(subject.to_ctx(subject['format']).to_hash.key?('rft.title')).to be false
        # expect(subject.to_ctx(subject['format']).to_hash['rft.atitle']).to eq(subject['title_citation_display'].first)
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
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('unknown')
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
        expect(subject.standard_numbers?).to be true
      end
    end

    context 'Without standard numbers' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns false when no standard number keys are present' do
        expect(subject.standard_numbers?).to be false
      end
    end
  end

  describe 'voyager_record?' do
    context 'A voyager record' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns true with a voyager record' do
        expect(subject.voyager_record?).to be true
      end
    end

    context 'A non-voyager record' do
      let(:properties) do
        {
          'id' => 'dsp1213313'
        }
      end

      it 'returns false when it did not originate from voyager' do
        expect(subject.voyager_record?).to be false
      end
    end
  end

  describe 'ark' do
    context 'there is no value' do
      it 'returns nil' do
        expect(subject.ark).to be_nil
      end
    end
    context 'when it has no ark in 1display' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'test' => 'one' }.to_json
        }
      end

      it 'returns nil' do
        expect(subject.ark).to be_nil
      end
    end
    context 'when it has an ark in 1display' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'http://arks.princeton.edu/ark:/88435/fj236339x' => 'one' }.to_json
        }
      end

      it 'returns the ark' do
        expect(subject.ark).to eq 'ark:/88435/fj236339x'
      end
    end
    context 'when it has multiple options only one an ark' do
      let(:properties) do
        {
          'electronic_access_1display' => { 'one' => 'two', 'http://arks.princeton.edu/ark:/88435/fj236339x' => 'one' }.to_json
        }
      end

      it 'returns the ark' do
        expect(subject.ark).to eq 'ark:/88435/fj236339x'
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
        expect(subject.export_formats).to have_key :endnote
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
        expect(subject.export_formats).not_to have_key :endnote
      end
    end

    context 'with a SCSB record' do
      let(:properties) do
        {
          'id' => 'SCSB-6593031'
        }
      end

      it 'does not include voyager-only formats' do
        expect(subject.export_formats).not_to have_key :endnote
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
      expect(subject.doc_electronic_access).to be_a Hash
      expect(subject.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(subject.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end

    context 'with IIIF Manifest URLs indexed' do
      let(:properties) do
        {
          'electronic_access_1display' => '{"https://pulsearch.princeton.edu/catalog/4609321#view":["arks.princeton.edu"],"https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs":["drive.google.com","Curatorial documentation"],"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/7d278t10z":"https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest","http://arks.princeton.edu/ark:/88435/xp68kg247":"https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest"}}'
        }
      end
      it 'does not expose the manifest URLs' do
        expect(subject.doc_electronic_access).to be_a Hash
        expect(subject.doc_electronic_access).not_to have_key('iiif_manifests')
        expect(subject.doc_electronic_access).to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
        expect(subject.doc_electronic_access).to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
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
      expect(subject.iiif_manifests).to be_a Hash
      expect(subject.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/7d278t10z' => 'https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest'
      expect(subject.iiif_manifests).to include 'http://arks.princeton.edu/ark:/88435/xp68kg247' => 'https://figgy.princeton.edu/concern/scanned_resources/42570d35-13b3-4bce-8fd0-7e465decb0e1/manifest'
      expect(subject.iiif_manifests).not_to include 'https://pulsearch.princeton.edu/catalog/4609321#view' => ['arks.princeton.edu']
      expect(subject.iiif_manifests).not_to include 'https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs' => ['drive.google.com', 'Curatorial documentation']
    end
  end
end
