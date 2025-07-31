# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NumismaticsFormSearchBuilder, advanced_search: true do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#do_not_limit_configured_facets' do
    context 'when fields are configured' do
      let(:blacklight_config) do
        Blacklight::Configuration.new do |config|
          config.numismatics_search ||= Blacklight::OpenStructWithHashAccess.new
          config.numismatics_search[:facet_fields] ||= %w[issue_metal_s issue_city_s find_place_s]
        end
      end

      it 'adds facet limits of -1 for all configured facet fields' do
        solr_params = {}
        builder.do_not_limit_configured_facets(solr_params)
        expect(solr_params).to eq({
                                    'f.issue_metal_s.facet.limit' => '-1',
                                    'f.issue_city_s.facet.limit' => '-1',
                                    'f.find_place_s.facet.limit' => '-1'
                                  })
      end
    end
  end
end
