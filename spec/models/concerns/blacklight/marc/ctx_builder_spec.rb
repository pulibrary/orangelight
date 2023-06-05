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
    context 'when title exists in solr' do
      context 'with a short title' do
        let(:document) { SolrDocument.new('title_citation_display': ['Potato handbook']) }
        it 'uses the full title for the title fields' do
          expect(builder.build.referent.get_metadata('title')).to eq('Potato handbook')
        end
      end
      context 'with a very long title' do
        let(:document) { SolrDocument.new('title_citation_display': ["Essai sur l'éducation des aveugles, ou, Exposé de différens moyens, vérifiés par l'expérience, pour les mettre en état de lire, à l'aide du tact, d'imprimer des livres dans lesquels ils puissent prendre des connoissances de langues, d'histoire, de géographie, de musique, &c., d'exécuter différens travaux relatifs aux métiers, &c. : dédié au Roi"]) }
        it 'uses a truncated title for the title fields' do
          expect(builder.build.referent.get_metadata('title')).to eq("Essai sur l'éducation des aveugles, ou, Exposé de différens moyens, vérifiés par l'expérience, pour les mettre en état de lire, à l'aide du tact, d'imprimer des livres dans lesquels ils puissent prendre des connoissances de langues, d'hist...")
          expect(builder.build.referent.get_metadata('title').length).to eq(250)
        end
      end
    end
  end
end
