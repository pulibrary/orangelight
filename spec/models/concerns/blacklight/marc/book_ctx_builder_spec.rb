# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Marc::BookCtxBuilder do
  let(:document) { SolrDocument.new(edition_display: ['Fifth edition']) }
  let(:format) { 'Journal/Magazine' }
  let(:builder) { described_class.new(document:, format:) }
  describe '#build' do
    it 'uses the edition info from the solr document' do
      expect(builder.build.referent.get_metadata('edition')).to eq 'Fifth edition'
    end
  end
end
