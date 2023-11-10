# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::HighlightPresenter do
  context 'When the FlipFlop is On' do
    before do
      allow(Flipflop).to receive(:highlighting?).and_return(true)
    end

    let(:document) { SolrDocument.new({ 'id' => 'doc1', 'title_field' => 'doc1 title', 'author_field' => 'author_someone' }, 'highlighting' => { 'doc1' => { 'title_tsimext' => ['doc <em>1</em>'] } }) }
    let(:field_config) { Blacklight::Configuration::Field.new(field: 'title_display') }
    let(:presenter) { described_class.new(nil, document, field_config) }

    it 'sets highlight true' do
      expect(presenter.field_config.highlight).to be_truthy
    end
  end
end
