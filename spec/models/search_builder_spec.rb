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

  describe '#facets_for_advanced_search_form', advanced_search: true do
    before do
      blacklight_config.advanced_search.form_solr_parameters = { 'facet.field' => ["issue_denomination_s"] }
    end

    context 'with the built-in advanced search form', advanced_search: true do
      it 'includes the advanced search facets' do
        solr_p = { fq: ["{!lucene}{!query v=$f_inclusive.issue_denomination_s.0} OR {!query v=$f_inclusive.issue_denomination_s.1}", nil, "format:Coin"] }
        search_builder.facets_for_advanced_search_form(solr_p)
        expect(solr_p[:fq]).to eq(['format:Coin'])
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
end
