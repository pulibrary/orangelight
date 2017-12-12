require 'rails_helper'

describe BlacklightHelper do
  let(:blacklight_params) {}

  before do
    allow(self).to receive(:blacklight_params).and_return(blacklight_params)
  end

  describe '#left_anchor_strip' do
    it 'strips white spaces before sending :q to solr' do
      query = { q: '{!qf=$left_anchor_qf pf=$left_anchor_pf}searching for' }
      left_anchor_strip(query)
      expect(query[:q]).to eq '{!qf=$left_anchor_qf pf=$left_anchor_pf}searchingfor'
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
end
