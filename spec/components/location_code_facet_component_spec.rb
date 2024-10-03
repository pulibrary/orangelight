# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationCodeFacetComponent, type: :component do
  before { stub_holding_locations }

  describe '#location_codes_by_lib' do
    let(:location_items) { [architecture, arch_la, recap_arch_pw, arch_newbook, arch_ref, arch_res3hr, arch_resclosed, arch_stacks, arch_unassigned] }
    let(:architecture) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'Architecture Library') }
    let(:arch_la) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$la') }
    let(:arch_newbook) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$newbook') }
    let(:recap_arch_pw) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$pw') }
    let(:arch_ref) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$ref') }
    let(:arch_res3hr) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$res3hr') }
    let(:arch_resclosed) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$resclosed') }
    let(:arch_stacks) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$stacks') }
    let(:arch_unassigned) { Blacklight::Solr::Response::Facets::FacetItem.new(hits: '792', value: 'arch$UNASSIGNED') }

    subject(:codes) do
      component = described_class.new(display_facet: nil, label: 'label', blacklight_config: nil, search_state: nil)
      component.location_codes_by_lib(location_items)
    end

    it 'includes library name as key' do
      expect(codes.key?('Architecture Library')).to be true
    end
    describe 'architecture library' do
      let(:architecture_hash) { subject['Architecture Library'] }

      it 'includes holding location code facet items' do
        expect(architecture_hash['codes']).to match_array([recap_arch_pw, arch_la, arch_newbook, arch_ref, arch_res3hr, arch_resclosed, arch_stacks, arch_unassigned])
      end
      it 'includes recap location code facet items' do
        expect(architecture_hash['recap_codes']).to include(recap_arch_pw)
      end
      it 'includes library facet item' do
        expect(architecture_hash['item']).to eq(architecture)
      end
    end
  end
end
