require 'rails_helper'

RSpec.describe AdvancedHelper do
  let(:architecture) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'Architecture Library') }
  let(:rcppw) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'rcppw') }
  let(:ues) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'ues') }
  let(:uesla) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'uesla') }
  let(:uesrf) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'uesrf') }
  let(:location_items) { [architecture, rcppw, ues, uesla, uesrf] }

  describe '#location_codes_by_lib' do
    let(:subject) { location_codes_by_lib(location_items) }
    it 'includes library name as key' do
      expect(subject.key?('Architecture Library')).to be true
    end
    describe 'architecture library' do
      let(:architecture_hash) { subject['Architecture Library'] }
      it 'includes holding location code facet items' do
        expect(architecture_hash['codes']).to match_array([ues, uesla, uesrf])
      end
      it 'includes recap location code facet items' do
        expect(architecture_hash['recap_codes']).to match_array([rcppw])
      end
      it 'includes library facet item' do
        expect(architecture_hash['item']).to eq(architecture)
      end
    end
  end
end
