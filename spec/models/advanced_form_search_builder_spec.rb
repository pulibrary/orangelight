# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AdvancedFormSearchBuilder do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#do_not_limit_facets' do
    it 'modifies existing facet limits to -1' do
      solr_params = { "f.instrumentation_facet.facet.limit" => "11" }
      builder.do_not_limit_facets(solr_params)
      expect(solr_params).to eq({ "f.instrumentation_facet.facet.limit" => "-1" })
    end

    it 'does not affect solr parameters unrelated to facet limits' do
      solr_params = { "rows" => "20" }
      expect do
        builder.do_not_limit_facets(solr_params)
      end.not_to(change { solr_params })
    end
  end
end
