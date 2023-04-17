# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Marc::CtxBuilder do
  let(:document) { SolrDocument.new }
  let(:format) { 'conference' }
  let(:builder) { described_class.new(document:, format:) }
  describe '#build' do
    it 'returns a ContextObject object' do
      expect(builder.build.class).to eq(OpenURL::ContextObject)
    end
    it 'applies the requested format' do
      expect(builder.build.referent.get_metadata('format')).to eq 'conference'
    end
    context 'when format is conference' do
      it 'genre metadata is conference' do
        expect(builder.build.referent.get_metadata('genre')).to eq('conference')
      end
    end
    context 'when no author' do
      it 'creator metadata is nil' do
        expect(builder.build.referent.get_metadata('creator')).to be_nil
      end
    end
    context 'when author exists in solr' do
      let(:document) { SolrDocument.new('author_citation_display': ['Miguel de Cervantes']) }
      it 'creator metadata is taken from solr' do
        expect(builder.build.referent.get_metadata('creator')).to eq('Miguel de Cervantes')
      end
    end
    context 'when publisher exists in solr' do
      let(:document) { SolrDocument.new('pub_citation_display': ['Penguin', 'Random House']) }
      it 'publisher is used for the aucorp and pub fields' do
        expect(builder.build.referent.get_metadata('aucorp')).to eq('Penguin')
        expect(builder.build.referent.get_metadata('pub')).to eq('Penguin')
      end
    end
  end
end
