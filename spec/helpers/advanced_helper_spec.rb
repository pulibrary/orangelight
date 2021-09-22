# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvancedHelper do
  let(:architecture) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'Architecture Library') }
  let(:rcppw) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$pw') }
  let(:ues) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$circ') }
  let(:uesla) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$la') }
  let(:uesrf) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$ref') }
  let(:location_items) { [architecture, rcppw, ues, uesla, uesrf] }

  before { stub_holding_locations }

  describe '#location_codes_by_lib' do
    subject(:codes) { location_codes_by_lib(location_items) }

    it 'includes library name as key' do
      expect(codes.key?('Architecture Library')).to be true
    end
    describe 'architecture library' do
      let(:architecture_hash) { subject['Architecture Library'] }

      it 'includes holding location code facet items' do
        # In Voyager the `architecture_hash['codes']` did not include the ReCAP library (rcppw)
        # since ReCAP items were assigned to their own library (ReCAP). That is not the case
        # in Alma and now the ReCAP library (rcppw) is included.
        expect(architecture_hash['codes']).to match_array([ues, uesla, uesrf, rcppw])
      end
      it 'includes recap location code facet items' do
        expect(architecture_hash['recap_codes']).to include(rcppw)
      end
      it 'includes library facet item' do
        expect(architecture_hash['item']).to eq(architecture)
      end
    end
  end
end
