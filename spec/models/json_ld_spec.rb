# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::JsonLd do
  subject(:document) { solr_doc.export_as_jsonld }
  let(:doc) { JSON.parse(document) }

  let(:fixture_path) { "spec/fixtures/alma/#{id}.json" }
  let(:fixture_file) { File.read(fixture_path) }
  let(:properties) { JSON.parse(fixture_file) }
  let(:solr_doc) { SolrDocument.new(properties) }

  describe '#export_as_jsonld' do
    context 'with a standard MARC Record' do
      let(:id) { '9996180723506421' }

      it 'creates a jsonld document' do
        expect(doc['@context']).to eq('http://localhost:3000/context.json')
        expect(doc['@id']).to eq('http://localhost:3000/catalog/9996180723506421')
        expect(doc['title']).to be_instance_of Array
        expect(doc['title'].first).to be_instance_of Hash
        expect(doc['title'].size).to eq 2
        expect(doc['title'].first['@value']).to eq(properties['title_vern_display'])
        expect(doc['title'].first['@language']).to eq('kor')
        expect(solr_doc.vernacular_title).to eq({
                                                  '@value' => "역주 불설 아미타경 언해 ; 역주 불정심 다라니경 언해 / 역주 위원 김 무봉 ; 편집 위원장 박 종국.",
                                                  '@language' => "kor"
                                                })
        expect(solr_doc.roman_title).to eq({
                                             '@value' => properties['title_display'],
                                             '@language' => "kor-Latn"
                                           })
        expect(doc['language']).to eq('kor')
        expect(doc['editor']).to eq(['Pak, Chong-guk, 1935-', '박 종국, 1935-'])
        expect(doc['created']).to eq("2008-01-01T00:00:00Z")
        expect(doc['date']).to eq('2008')
        expect(doc['identifier']).to be nil
        expect(doc['location']).to eq(['ReCAP BQ2043.K6 T757 2008'])
      end
    end
    context 'with an English-language journal' do
      let(:id) { '995597013506421' }

      it 'creates a jsonld document' do
        expect(doc['@context']).to eq('http://localhost:3000/context.json')
        expect(doc['@id']).to eq('http://localhost:3000/catalog/995597013506421')
        expect(doc['title'].size).to eq 1
        expect(doc['title'].first['@language']).to eq('eng')
        expect(doc['language']).to eq('eng')
        expect(doc['contributor']).to eq(["New York Botanical Garden", "Mycological Society of America"])
        expect(doc['created']).to eq("1909-01-01T00:00:00Z/9999-12-31T23:59:59Z")
        expect(doc['date']).to eq('1909-9999')
      end
    end
    context 'with an artwork' do
      let(:id) { '99106471643506421' }

      it 'creates a jsonld document' do
        expect(doc['creator']).to eq("Avery, Eric, born 1948")
        expect(doc['created']).to eq("1984-01-01T00:00:00Z")
        expect(doc['date']).to eq('1984')
      end
    end

    context 'with a monograph with an author' do
      let(:id) { '9956200533506421' }

      it 'creates a jsonld document' do
        expect(doc['creator']).to eq("Dagen, Philippe")
        expect(doc['author']).to eq("Dagen, Philippe")
        expect(doc['created']).to eq("2008-01-01T00:00:00Z")
        expect(doc['date']).to eq('2008')
      end
    end

    context 'with a special collections codex' do
      let(:id) { '9952615993506421' }
      it 'creates a jsonld document' do
        expect(doc['abstract']).to include('an abridgment of part 3 of Miftāḥ al-ʻulūm')
      end
    end

    context 'with a digitized manuscript' do
      let(:id) { '9946093213506421' }

      it 'creates a jsonld document' do
        expect(doc['identifier']).to eq("http://arks.princeton.edu/ark:/88435/7d278t10z")
        expect(doc['electronic_locations']).to eq([{
                                                    "@id" => "https://catalog.princeton.edu/catalog/4609321#view",
                                                    "label" => ["Digital content"]
                                                  },
                                                   {
                                                     "@id" => "https://drive.google.com/open?id=0B3HwfRG3YqiNVVR4bXNvRzNwaGs",
                                                     "label" => ["drive.google.com", "Curatorial documentation"]
                                                   },
                                                   {
                                                     "@id" => "iiif_manifest_paths",
                                                     "label" => { "http://arks.princeton.edu/ark:/88435/7d278t10z" => "https://figgy.princeton.edu/concern/scanned_resources/d446107a-bdfd-4a5d-803c-f315b7905bf4/manifest" }
                                                   }])
      end
    end
  end
end
