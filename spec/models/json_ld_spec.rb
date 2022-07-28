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
    context 'For a standard MARC Record' do
      let(:id) { '9996180723506421' }

      it 'creates a jsonld document' do
        expect(doc['@context']).to eq('http://bibdata.princeton.edu/context.json')
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
      end
    end
    context 'For an English-language journal' do
      let(:id) { '995597013506421' }

      it 'creates a jsonld document' do
        expect(doc['@context']).to eq('http://bibdata.princeton.edu/context.json')
        expect(doc['@id']).to eq('http://localhost:3000/catalog/995597013506421')
        expect(doc['title'].size).to eq 1
        expect(doc['title'].first['@language']).to eq('eng')
        expect(doc['language']).to eq('eng')
      end
    end
    context 'For an artwork' do
      let(:id) { '99106471643506421' }

      it 'creates a jsonld document' do
        expect(doc['creator']).to eq("Avery, Eric, born 1948")
      end
    end
  end
end
