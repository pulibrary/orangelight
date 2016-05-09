require 'rails_helper'

describe BlacklightHelper do
  describe 'left_anchor_strip' do
    it 'strips white spaces before sendning :q to solr' do
      query = { q: "{!qf=$left_anchor_qf pf=$left_anchor_pf}searching for" }
      left_anchor_strip(query, {})
      expect(query[:q]).to eq "{!qf=$left_anchor_qf pf=$left_anchor_pf}searchingfor"
    end
  end

  describe 'cjk_mm' do
    it 'uses cjk_mm value for all cjk search' do
      query = { q: "毛沢東" }
      solr_params = {}
      cjk_mm(solr_params, query)
      expect(solr_params['mm']).to eq cjk_mm_val
    end
    it 'requires all non cjk characters when mixed with cjk in search' do
      query = { q: "毛沢東 dai" }
      solr_params = {}
      cjk_mm(solr_params, query)
      expect(solr_params['mm']).to eq "4<86%"
    end
    it 'uses default mm value for non cjk search' do
      query = { q: "hello regular search" }
      solr_params = {}
      cjk_mm(solr_params, query)
      expect(solr_params['mm']).to be nil
    end
  end
end
