# frozen_string_literal: true

require 'rails_helper'

describe BlacklightHelper do
  let(:blacklight_params) {}

  before do
    allow(self).to receive(:blacklight_params).and_return(blacklight_params)
  end

  describe '#left_anchor_escape_whitespace' do
    it 'escapes white spaces before sending :q to solr along with wildcard character' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}searching for a test value' }
      left_anchor_escape_whitespace(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}searching\ for\ a\ test\ value*'
    end
    it 'only a single wildcard character is included when user supplies the wildcard in query' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}searching for a test value*' }
      left_anchor_escape_whitespace(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}searching\ for\ a\ test\ value*'
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
      '<a data-context-href="/catalog/1/track?counter=1&amp;search_id=5" href="/catalog/1">Catalogue of a collection of angling books : consisting of 788 volumes on the sport : a set (18 vols.) of the works of Charles Cotton : an ichtyological library (109 vols.) : and a &quot;Waltonian ...</a>'
    end

    before do
      allow(view).to receive(:blacklight_config).and_return(blacklight_config)
      allow(helper).to receive(:document_link_params).and_return(data: { :"context-href" => '/catalog/1/track?counter=1&search_id=5' })
      allow(helper).to receive(:url_for_document).and_return(document)
    end

    it 'truncates the content of a field before linking it' do
      expect(helper.truncated_link(document, helper.document_show_link_field(document))).to eq truncated
    end
  end
end
