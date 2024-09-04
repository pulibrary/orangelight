# frozen_string_literal: true

require 'rails_helper'

describe BlacklightHelper do
  let(:blacklight_params) { {} }

  before do
    allow(self).to receive(:blacklight_params).and_return(blacklight_params)
    allow(self).to receive(:current_or_guest_user).and_return(User.new)
    allow(self).to receive(:search_action_path) do |*args|
      search_catalog_url(*args)
    end
  end

  describe '#prepare_left_anchor_search', left_anchor: true do
    before do
      allow(Flipflop).to receive(:json_query_dsl?).and_return(false)
    end
    it 'escapes white spaces before sending :q to solr along with wildcard character' do
      query = { qf: '${left_anchor_qf}', pf: '${left_anchor_pf}', q: 'searching for a test value' }
      prepare_left_anchor_search(query)
      expect(query[:q]).to eq 'searching\ for\ a\ test\ value*'
    end
    it 'only a single wildcard character is included when user supplies the wildcard in query' do
      query = { qf: '${left_anchor_qf}', pf: '${left_anchor_pf}', q: 'searching for a test value*' }
      prepare_left_anchor_search(query)
      expect(query[:q]).to eq 'searching\ for\ a\ test\ value*'
    end
    context 'with the json query dsl' do
      before do
        allow(Flipflop).to receive(:json_query_dsl?).and_return(true)
      end
      it 'escapes white spaces before sending :query to solr along with wildcard character' do
        query = { "qt" => nil, "json" => { "query" => { "bool" => { "must" => [
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "searching for a test value"
            } }
        ] } } } }
        # query = { qf: '${left_anchor_qf}', pf: '${left_anchor_pf}', q: 'searching for a test value' }
        prepare_left_anchor_search(query)
        expect(query["json"]["query"]["bool"]["must"][0][:edismax][:query]).to eq 'searching\ for\ a\ test\ value*'
      end
      it 'only a single wildcard character is included when user supplies the wildcard in query' do
        query = { "qt" => nil, "json" => { "query" => { "bool" => { "must" => [
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "searching for a test value*"
            } }
        ] } } } }
        prepare_left_anchor_search(query)
        expect(query["json"]["query"]["bool"]["must"][0][:edismax][:query]).to eq 'searching\ for\ a\ test\ value*'
      end
    end
    context 'with a complex boolean advanced search' do
      before do
        allow(Flipflop).to receive(:json_query_dsl?).and_return(true)
        allow(Flipflop).to receive(:view_components_advanced_search?).and_return(true)
      end
      it 'escapes all left_anchor terms' do
        query = { "qt" => nil, "json" => { "query" => { "bool" => { "must" => [
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "searching for"
            } },
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "searching for"
            } },
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "searching for"
            } }
        ] } } } }
        prepare_left_anchor_search(query)
        expect(query.dig('json', 'query', 'bool', 'must', 0, :edismax, :query)).to eq("searching\\ for*")
        expect(query.dig('json', 'query', 'bool', 'must', 1, :edismax, :query)).to eq("searching\\ for*")
        expect(query.dig('json', 'query', 'bool', 'must', 2, :edismax, :query)).to eq("searching\\ for*")
      end
      it 'escapes all left_anchor terms' do
        query = { "qt" => nil, "json" => { "query" => { "bool" => { "must" => [
          { edismax:
            {
              query: "lord of the rings"
            } },
          { edismax:
            {
              qf: "${left_anchor_qf}",
              pf: "${left_anchor_pf}",
              query: "lord"
            } }
        ] } } } }
        expect(left_anchor_search?(query)).to be true
      end
    end
  end

  describe '#html_facets' do
    let(:solr_parameters) { {} }

    describe 'when blacklight format param nil' do
      let(:blacklight_params) { {} }

      it 'solr facet param is unaffected' do
        html_facets(solr_parameters)
        expect(solr_parameters[:facet]).to be_nil
      end
    end
    describe 'when blacklight format param is rss' do
      let(:blacklight_params) { { format: 'rss' } }

      it 'solr facet param is set to false' do
        html_facets(solr_parameters)
        expect(solr_parameters[:facet]).to eq false
      end
    end
  end

  describe '#cjk_mm' do
    context 'when the search is all cjk' do
      let(:blacklight_params) { { q: '毛沢東' } }

      it 'uses the cjk_mm value' do
        solr_params = {}
        cjk_mm(solr_params)
        expect(solr_params['mm']).to eq cjk_mm_val
      end
    end

    context 'when mixed with cjk in search' do
      let(:blacklight_params) { { q: '毛沢東 dai' } }

      it 'requires all non cjk characters' do
        solr_params = {}
        cjk_mm(solr_params)
        expect(solr_params['mm']).to eq '4<86%'
      end
    end

    context 'when there is a non cjk search' do
      let(:blacklight_params) { { q: 'hello regular search' } }

      it 'uses the default mm value' do
        solr_params = {}
        cjk_mm(solr_params)
        expect(solr_params['mm']).to be nil
      end
    end
  end

  describe '#wildcard_char_strip', left_anchor: true do
    it 'strips question marks which are wildcard characters before sending :q to solr' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience?' }
      wildcard_char_strip(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience'
    end
  end

  describe '#render_facet_partials' do
    let(:blacklight_config) { Blacklight::Configuration.new }

    before do
      allow(helper).to receive(:blacklight_config).and_return blacklight_config
      allow(Rails.logger).to receive(:error)
      allow(helper).to receive(:render_home_facets).and_call_original
      allow(helper).to receive(:facets_from_request).and_raise(StandardError)
      allow(helper).to receive(:head)
    end
  end

  describe "#link_back_to_catalog_safe" do
    context "with valid parameters" do
      let(:valid_session) { instance_double(Search) }
      it "produces a link" do
        allow(valid_session).to receive(:query_params).and_return(
          action: "show", controller: "catalog", id: "123"
        )
        allow(helper).to receive(:current_search_session).and_return(valid_session)
        allow(helper).to receive(:blacklight_config).and_return(CatalogController.new.blacklight_config)
        allow(helper).to receive(:search_session).and_return({})
        expect(helper.link_back_to_catalog_safe).to include("/catalog/123")
      end
    end

    context "invalid parameters" do
      let(:invalid_session) { instance_double(Search) }
      it "produces a default link (i.e. does not crash)" do
        allow(invalid_session).to receive(:query_params).and_return(
          action: "index", controller: "advanced", id: "123"
        )
        allow(helper).to receive(:current_search_session).and_return(invalid_session)
        allow(helper).to receive(:blacklight_config).and_return(CatalogController.new.blacklight_config)
        allow(helper).to receive(:search_session).and_return({})
        expect(helper.link_back_to_catalog_safe).to include("http://test.host/")
      end
    end
  end
end
