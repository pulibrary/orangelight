# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NewAdvancedFormSearchBuilder, advanced_search: true do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#no_documents' do
    it 'adds rows=0' do
      solr_params = {}
      builder.no_documents(solr_params)
      expect(solr_params).to eq({ "rows" => 0 })
    end
  end
end
