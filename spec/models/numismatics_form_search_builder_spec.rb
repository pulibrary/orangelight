# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NumismaticsFormSearchBuilder, advanced_search: true do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.numismatics_search ||= Blacklight::OpenStructWithHashAccess.new
      config.numismatics_search[:facet_fields] ||= %w[issue_metal_s issue_city_s find_place_s]
    end
  end
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#fetch_configured_facets' do
    it 'sets the facet.field' do
      solr_params = {}
      builder.fetch_configured_facets(solr_params)
      expect(solr_params['facet.field']).to eq %w[issue_metal_s issue_city_s find_place_s]
    end
  end
  describe '#do_not_limit_configured_facets' do
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
  describe '#ensure_format_coin_is_the_only_fq' do
    it 'sets removes all fq except format:Coin' do
      solr_params = { fq: ['{!tag=pub_date_start_sort_single}pub_date_start_sort:[-91 TO 9999]', '{!term f=issue_metal_s}copper', 'format:Coin'] }
      builder.ensure_format_coin_is_the_only_fq(solr_params)
      expect(solr_params[:fq]).to eq ['format:Coin']
    end
  end
end
