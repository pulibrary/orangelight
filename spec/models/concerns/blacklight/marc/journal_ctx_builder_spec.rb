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
  end
end
