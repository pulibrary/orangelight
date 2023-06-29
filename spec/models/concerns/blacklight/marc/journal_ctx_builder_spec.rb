# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Marc::JournalCtxBuilder do
  let(:document) { SolrDocument.new(author_citation_display: ['Nature Editors']) }
  let(:format) { 'Journal/Magazine' }
  let(:builder) { described_class.new(document:, format:) }
  describe '#build' do
    it 'has a genre of serial' do
      expect(builder.build.referent.get_metadata('genre')).to eq 'serial'
    end
    context 'when author available in solr' do
      it 'considers it to be a corporate author' do
        expect(builder.build.referent.get_metadata('aucorp')).to eq 'Nature Editors'
      end
    end
    context 'when title_citation_display available in solr' do
      let(:document) { SolrDocument.new(title_citation_display: ['Science']) }
      it 'uses it as the atitle' do
        expect(builder.build.referent.get_metadata('atitle')).to eq 'Science'
      end
    end
    context 'when oclc number is available in solr' do
      let(:document) { SolrDocument.new(oclc_s: ['10708673']) }
      it 'uses it as the OCLC number' do
        expect(builder.build.referent.identifiers).to include('info:oclcnum/10708673')
      end
    end
  end
end
