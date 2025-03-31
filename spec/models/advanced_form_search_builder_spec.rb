# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AdvancedFormSearchBuilder, advanced_search: true do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  context 'with advanced search configuration' do
    let(:blacklight_config) { Blacklight::Configuration.new }
    before do
      blacklight_config.advanced_search.form_solr_parameters = { 'f.publication_place_facet.facet.limit' => '-1' }
      blacklight_config.advanced_search.form_solr_parameters['facet.field'] = %w[access_facet format publication_place_facet language_facet advanced_location_s]
    end
    describe '#do_not_limit_languages' do
      it 'does not limit the language facet based on the advanced_search configuration' do
        solr_params = { "f.publication_place_facet.facet.limit" => "11" }
        builder.use_advanced_configuration(solr_params)
        expect(solr_params).to eq({ "f.publication_place_facet.facet.limit" => "-1" })
      end

      it 'does not modify other facet limits' do
        solr_params = { "f.instrumentation_facet.facet.limit" => "11" }
        expect do
          builder.use_advanced_configuration(solr_params)
        end.not_to(change { solr_params })
      end

      it 'does not affect solr parameters unrelated to facet limits' do
        solr_params = { "rows" => "20" }
        expect do
          builder.use_advanced_configuration(solr_params)
        end.not_to(change { solr_params })
      end
    end
  end

  describe '#only_request_advanced_facets' do
    let(:blacklight_config) { CatalogController.blacklight_config }

    it 'removes unnecessary facet.field entries' do
      builder.with({ action: 'advanced_search' })
      solr_params = { "facet.field" => %w[genre_facet subject_era_facet geographic_facet] }

      builder.only_request_advanced_facets(solr_params)

      expect(solr_params['facet.field']).not_to include 'genre_facet'
      expect(solr_params['facet.field']).not_to include 'subject_era_facet'
      expect(solr_params['facet.field']).not_to include 'geographic_facet'
    end

    it 'adds the needed facet.field entries' do
      builder.with({ action: 'advanced_search' })
      solr_params = { "facet.field" => %w[genre_facet subject_era_facet geographic_facet] }

      builder.only_request_advanced_facets(solr_params)

      expect(solr_params['facet.field']).to include 'language_facet'
    end

    it 'removes unneeded params' do
      builder.with({ action: 'advanced_search' })
      solr_params = {
        "facet.pivot" => %w[lc_1letter_facet lc_rest_facet],
        "facet.query" => ['cataloged_tdt:[NOW/DAY-7DAYS TO NOW/DAY+1DAY]', 'cataloged_tdt:[NOW/DAY-14DAYS TO NOW/DAY+1DAY]'],
        "stats" => true,
        "stats.field" => "pub_date_start_sort"
      }

      builder.only_request_advanced_facets(solr_params)

      expect(solr_params.keys).not_to include 'facet.query'
      expect(solr_params.keys).not_to include 'facet.pivot'
      expect(solr_params.keys).not_to include 'stats'
      expect(solr_params.keys).not_to include 'stats.field'
      expect(solr_params.keys).to include 'facet.field'
    end
  end

  describe '#no_documents' do
    it 'adds rows=0' do
      solr_params = {}
      builder.no_documents(solr_params)
      expect(solr_params).to eq({ "rows" => 0 })
    end
  end
end
