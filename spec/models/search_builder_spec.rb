# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchBuilder do
  subject(:search_builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  describe '#excessive_paging' do
    let(:excessive) { 9999 }
    let(:reasonable) { 123 }

    it 'allows reasonable paging with a search query' do
      search_builder.blacklight_params[:page] = reasonable
      search_builder.blacklight_params[:q] = 'anything'
      expect(search_builder.excessive_paging?).to be false
    end

    it 'allows reasonable paging with a facet query' do
      search_builder.blacklight_params[:page] = reasonable
      search_builder.blacklight_params[:f] = 'anything'
      expect(search_builder.excessive_paging?).to be false
    end

    it 'does not allow paging without a search or facet' do
      search_builder.blacklight_params[:page] = reasonable
      expect(search_builder.excessive_paging?).to be true
    end

    it 'does not allow excessive paging with a search query' do
      search_builder.blacklight_params[:page] = excessive
      search_builder.blacklight_params[:q] = 'anything'
      expect(search_builder.excessive_paging?).to be true
    end

    it 'does not allow excessive paging with a facet query' do
      search_builder.blacklight_params[:page] = excessive
      search_builder.blacklight_params[:f] = 'anything'
      expect(search_builder.excessive_paging?).to be true
    end

    it 'allows paging for advanced search' do
      search_builder.blacklight_params[:page] = reasonable
      search_builder.blacklight_params[:search_field] = 'advanced'
      expect(search_builder.excessive_paging?).to be false
    end

    it 'handles query ending with empty parenthesis' do
      search_builder.blacklight_params[:q] = 'hello world ()'
      search_builder.parslet_trick({})
      expect(search_builder.blacklight_params[:q].end_with?("()")).to be false
    end
  end

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
          expect(solr_parameters[:q]).to eq('+solr +blacklight')
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

  describe '#facets_for_advanced_search_form' do
    before do
      blacklight_config.advanced_search.form_solr_parameters = { 'facet.field' => ["issue_denomination_s"] }
    end
    context 'when encountering a nil facet' do
      it 'removes nil and facets that need to be displayed on the form' do
        solr_p = { fq: ["{!lucene}{!query v=$f_inclusive.issue_denomination_s.0} OR {!query v=$f_inclusive.issue_denomination_s.1}", nil, "format:Coin"] }
        search_builder.facets_for_advanced_search_form(solr_p)
        expect(solr_p[:fq]).to eq(['format:Coin'])
      end
    end
  end
end
