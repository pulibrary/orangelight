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

  describe '#left_anchor_escape_whitespace' do
    it 'escapes white spaces before sending :q to solr along with wildcard character' do
      query = { qf: '${left_anchor_qf}', pf: '${left_anchor_pf}', q: 'searching for a test value' }
      left_anchor_escape_whitespace(query)
      expect(query[:q]).to eq 'searching\ for\ a\ test\ value*'
    end
    it 'only a single wildcard character is included when user supplies the wildcard in query' do
      query = { qf: '${left_anchor_qf}', pf: '${left_anchor_pf}', q: 'searching for a test value*' }
      left_anchor_escape_whitespace(query)
      expect(query[:q]).to eq 'searching\ for\ a\ test\ value*'
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

  describe '#wildcard_char_strip' do
    it 'strips question marks which are wildcard characters before sending :q to solr' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience?' }
      wildcard_char_strip(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}China and Angola: a marriage of convenience'
    end
  end

  describe '#truncated_link' do
    let(:blacklight_config) do
      CatalogController.new.blacklight_config
    end

    let(:document) do
      SolrDocument.new(
        'id' => '1',
        'title_display' => 'Catalogue of a collection of angling books : consisting of 788 volumes on the sport : a set (18 vols.) of the works of Charles Cotton : an ichtyological library (109 vols.) : and a "Waltonian Library" on assemblage of the books (38 vols.) cited by Walton in his "Compleat Angler" : manuscript, 1869.'
      )
    end

    let(:truncated) do
      '<a data-context-href="/catalog/1/track?counter=1&amp;search_id=5" href="/catalog/1">Catalogue of a collection of angling books : consisting of 788 volumes on the sport : a set (18 vols.) of the works of Charles Cotton : an ichtyological library (109 vols.) : and a "Waltonian...</a>'
    end

    before do
      allow(view).to receive(:blacklight_config).and_return(blacklight_config)
      allow(helper).to receive(:document_link_params).and_return(data: { "context-href": '/catalog/1/track?counter=1&search_id=5' })
      allow(helper).to receive(:url_for_document).and_return(document)
    end

    it 'truncates the content of a field before linking it' do
      expect(helper.truncated_link(document, :title_display)).to eq truncated
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

    it 'renders home facets when an error is encountered' do
      helper.render_facet_partials

      expect(Rails.logger).to have_received(:error).with(/Failed to render the facet partials for/)
      expect(helper).to have_received(:head).with(:bad_request)
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
