# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchBuilder do
  subject(:search_builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#cleanup_boolean_operators' do
    let(:solr_parameters) do
      { q: 'Douglas fir' }
    end
    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_search_field('all_fields')
      end
    end
    before do
      allow(subject).to receive(:blacklight_params).and_return(solr_parameters)
      allow(subject).to receive(:field_def).and_return([])
    end
    context 'when using edismax via a q param' do
      context 'when q does not contain boolean operators' do
        it 'does not change the q parameter' do
          subject.cleanup_boolean_operators(solr_parameters)
          expect(solr_parameters[:q]).to eq('Douglas fir')
        end
      end
      context 'when q contains a boolean operator' do
        let(:solr_parameters) do
          { q: 'solr AND blacklight' }
        end
        it 'parses the query' do
          subject.cleanup_boolean_operators(solr_parameters)
          expect(solr_parameters[:q]).to eq('solr AND blacklight')
        end
      end
      context 'when q contains an all-caps phrase that happens to contain a boolean operator' do
        let(:solr_parameters) do
          { q: 'I AM NOT YOUR PRINCESS' }
        end
        it 'knows that the user did not mean NOT in the boolean sense' do
          subject.cleanup_boolean_operators(solr_parameters)
          expect(solr_parameters[:q]).to eq('I AM not YOUR PRINCESS')
        end
      end
    end
    context 'when using the JSON query DSL' do
      let(:solr_parameters) do
        { "json" =>
          { "query" =>
            { "bool" =>
              { "must" =>
                [{ edismax: { query: "solr AND blacklight" } }] } } } }
      end
      it 'does not change the solr_parameters json query' do
        allow(subject).to receive(:blacklight_params).and_return({ q: 'solr AND blacklight' })
        expect do
          subject.cleanup_boolean_operators(solr_parameters)
        end.not_to change { solr_parameters['json'] }
      end
      context 'when user query contains an all-caps phrase that happens to contain a boolean operator' do
        let(:solr_parameters) do
          { "json" =>
            { "query" =>
              { "bool" =>
                { "must" =>
                  [{ edismax: { query: "I AM NOT YOUR PRINCESS" } }] } } } }
        end
        it 'knows that the user did not mean NOT in the boolean sense' do
          allow(subject).to receive(:blacklight_params).and_return({ q: 'I AM NOT YOUR PRINCESS' })
          subject.cleanup_boolean_operators(solr_parameters)
          expect(solr_parameters.dig('json', 'query', 'bool', 'must', 0, :edismax, :query)).to eq('I AM not YOUR PRINCESS')
        end
      end
    end
  end

  describe '#only_home_facets' do
    let(:blacklight_params) do
      { q: 'Douglas fir' }
    end
    before do
      allow(subject).to receive(:blacklight_params).and_return(blacklight_params)
      allow(subject).to receive(:blacklight_config).and_return(
        Blacklight::Configuration.new do |config|
          config.add_facet_field('access_facet', label: 'Access', home: true)
          config.add_facet_field('language_facet', label: 'Format')
        end
      )
    end
    context 'when there is no query' do
      let(:blacklight_params) do
        {}
      end
      it 'removes non-home facets from solr_parameters' do
        solr_parameters = { 'facet.field' => ['access_facet', 'language_facet'] }
        expect { search_builder.only_home_facets(solr_parameters) }.to change { solr_parameters }
        expect(solr_parameters['facet.field']).to eq(['access_facet'])
      end
    end
    context 'when there is a query in the q param' do
      it 'does not make any changes to the facets' do
        solr_parameters = { 'facet.field' => ['access_facet', 'language_facet'] }
        expect { search_builder.only_home_facets(solr_parameters) }.not_to change { solr_parameters }
      end
    end
    context 'when there is a query using the JSON query DSL' do
      let(:blacklight_params) do
        { 'clause' =>
          { '0' =>
            { 'query' => 'robots' } } }
      end
      it 'does not make any changes to the facets' do
        solr_parameters = { 'facet.field' => ['access_facet', 'language_facet'] }
        expect { search_builder.only_home_facets(solr_parameters) }.not_to change { solr_parameters }
      end
    end
    context 'when there is a facet suggest query' do
      let(:blacklight_params) do
        { "controller" => "catalog", "action" => "facet", "id" => "language_facet", "query_fragment" => "a", "only_values" => true }.with_indifferent_access
      end
      it 'does not make any changes to the facets' do
        solr_parameters = { 'facet.field' => ['access_facet', 'language_facet'] }
        expect { search_builder.only_home_facets(solr_parameters) }.not_to change { solr_parameters }
      end
    end
  end

  describe '#adjust_mm' do
    context 'when the query contains a boolean OR' do
      let(:blacklight_params) do
        { q: 'Douglas OR fir' }
      end
      it 'sets the mm to 0, meaning that we do not require all search terms to appear in the document' do
        allow(search_builder).to receive(:blacklight_params).and_return(blacklight_params)
        solr_parameters = {}

        expect { search_builder.adjust_mm(solr_parameters) }.to change { solr_parameters }
        expect(solr_parameters['mm']).to eq(0)
      end
      context 'with an advanced search' do
        let(:blacklight_params) do
          { advanced_type: "advanced", "clause" => { "0" => { "field" => "all_fields", "query" => "history OR abolition", "op" => "must" } } }
        end
        it 'sets the mm to 0, meaning that we do not require all search terms to appear in the document' do
          allow(search_builder).to receive(:blacklight_params).and_return(blacklight_params)
          solr_parameters = {}

          expect { search_builder.adjust_mm(solr_parameters) }.to change { solr_parameters }
          expect(solr_parameters['mm']).to eq(0)
        end
      end
    end
    context 'when the query does not contain a boolean OR' do
      let(:blacklight_params) do
        { q: 'Douglas AND fir for or maybe NOT' }
      end
      it 'does not adjust solr_parameters' do
        allow(search_builder).to receive(:blacklight_params).and_return(blacklight_params)
        solr_parameters = {}

        expect { search_builder.adjust_mm(solr_parameters) }.not_to change { solr_parameters }
      end
    end
  end

  describe '#remove_unneeded_facets' do
    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'pub_date_start_sort', label: 'Publication year', single: true, range: {
          num_segments: 10,
          assumed_boundaries: [1100, Time.zone.now.year + 1],
          segments: true
        }
        config.add_facet_field 'classification_pivot_field', label: 'Classification', pivot: %w[lc_1letter_facet lc_rest_facet]
        config.add_facet_field 'recently_added_facet', label: 'Recently added', home: true, query: {
          weeks_one: { label: 'Within 1 week', fq: 'cataloged_tdt:[NOW/DAY-7DAYS TO NOW/DAY+1DAY]' },
          weeks_two: { label: 'Within 2 weeks', fq: 'cataloged_tdt:[NOW/DAY-14DAYS TO NOW/DAY+1DAY]' }
        }
      end
    end
    context 'when viewing a facet that is not a pivot or stats facet' do
      before { search_builder.facet('language_facet') }
      it 'removes expensive stats configuration' do
        solr_parameters = { 'stats' => true, 'stats.field' => ['pub_date_start_sort'] }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters.keys).not_to include 'stats'
        expect(solr_parameters.keys).not_to include 'stats.field'
      end
      it 'removes expensive facet.pivot configuration' do
        solr_parameters = { 'facet.pivot' => 'lc_1letter_facet,lc_rest_facet' }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters.keys).not_to include 'facet.pivot'
      end
      it 'removes expensive facet.query configuration' do
        solr_parameters = { 'facet.query' => ['cataloged_tdt:[NOW/DAY-7DAYS+TO+NOW/DAY+1DAY]'] }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters.keys).not_to include 'facet.query'
      end
    end
    context 'when viewing a stats facet' do
      before { search_builder.facet('pub_date_start_sort') }
      it 'keeps the stats configuration' do
        solr_parameters = { 'stats' => true, 'stats.field' => ['pub_date_start_sort'] }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters['stats']).to be true
        expect(solr_parameters['stats.field']).to eq ['pub_date_start_sort']
      end
    end
    context 'when viewing a pivot facet' do
      before { search_builder.facet('lc_1letter_facet') }
      it 'keeps the facet.pivot configuration' do
        solr_parameters = { 'facet.pivot' => 'lc_1letter_facet,lc_rest_facet' }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters['facet.pivot']).to eq 'lc_1letter_facet,lc_rest_facet'
      end
    end
    context 'when viewing a facet that needs a facet.query' do
      before { search_builder.facet('cataloged_tdt') }
      it 'keeps the facet.query configuration' do
        solr_parameters = { 'facet.query' => ['cataloged_tdt:[NOW/DAY-7DAYS+TO+NOW/DAY+1DAY]'] }
        search_builder.remove_unneeded_facets(solr_parameters)
        expect(solr_parameters['facet.query']).to eq ['cataloged_tdt:[NOW/DAY-7DAYS+TO+NOW/DAY+1DAY]']
      end
    end
    context 'when we are not doing a facet view' do
      it 'does not modify the solr_parameters' do
        solr_parameters = { 'stats' => true, 'stats.field' => ['pub_date_start_sort'] }
        expect do
          search_builder.remove_unneeded_facets(solr_parameters)
        end.not_to change { solr_parameters }
      end
    end
  end
  describe '#wildcard_char_strip' do
    it 'strips question marks which are wildcard characters before sending :q to solr' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience?' }
      search_builder.wildcard_char_strip(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience'
    end
    it 'strips question marks from json query DSL queries' do
      query = { "json" =>
      { "query" =>
        { "bool" =>
          { "must" =>
            [{ edismax: { query: "China and Angola: a marriage of convenience?" } }] } } } }
      search_builder.wildcard_char_strip(query)
      expect(query['json']['query']['bool']['must'][0][:edismax][:query]).to eq 'China and Angola: a marriage of convenience'
    end
  end
end
