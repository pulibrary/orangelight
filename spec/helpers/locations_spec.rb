# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#locate_url helper method' do
    let(:stackmap_location) { 'mus' }
    let(:locator_location) { 'f' }
    let(:stackmap_ineligible_location) { 'annexa' }
    let(:bib) { { id: '123456' } }
    let(:call_number) { 'RCPXR-6136516' }
    let(:locator_library) { 'Firestone Library' }
    let(:stackmap_library) { 'Mendel Music Library' }
    let(:stackmap_ineligible_library) { 'Fine Annex' }

    before { stub_holding_locations }

    it 'Returns a Stackmap Link for a Mapping Location' do
      stackmap_link = locate_url(locator_location, bib, call_number, locator_library)
      expect(stackmap_link).to be_truthy
      expect(stackmap_link).to include("?loc=#{locator_location}&id=#{bib[:id]}")
    end

    it 'Does not return a stackmap link for an inaccessible location' do
      stackmap_link = locate_url(stackmap_ineligible_location, bib, call_number, stackmap_ineligible_library)
      expect(stackmap_link).to be_nil
    end

    it 'Does not return a stackmap link when there is no call number' do
      stackmap_link = locate_url(stackmap_location, bib, nil, stackmap_library)
      expect(stackmap_link).to be_nil
    end

    it 'Returns a locator link when there is no call number for Firestone' do
      locator_link = locate_url(locator_location, bib, nil, locator_library)
      expect(locator_link).to include("?loc=#{locator_location}&id=#{bib[:id]}")
    end
  end

  describe '#render_location_code' do
    before { stub_holding_locations }

    it 'returns value when value is not a valid location code' do
      value = 'blah'
      expect(render_location_code(value)).to eq value
    end

    it 'renders full location when value is a valid location code' do
      expect(render_location_code('clas')).to eq('clas: Firestone Library - Classics Collection (Clas)')
    end
  end

  describe '#holding_location_label' do
    let(:fallback) { 'Fallback' }
    let(:without_code) { { 'location' => fallback } }
    let(:invalid_code) { { 'location' => fallback, 'location_code' => 'invalid' } }
    let(:valid_code) { { 'location' => fallback, 'location_code' => 'clas' } }

    it 'returns holding location label when location code lookup successful' do
      stub_holding_locations
      expect(holding_location_label(valid_code)).to eq('Firestone Library - Classics Collection (Clas)')
    end
    it 'returns holding location value when location code lookup fails' do
      stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations.json")
        .to_return(status: 500,
                   body: '')
      expect(holding_location_label(invalid_code)).to eq(fallback)
    end
    it 'returns holding location value when no location code' do
      expect(holding_location_label(without_code)).to eq(fallback)
    end
    it 'returns nil when no location code or holding location value' do
      expect(holding_location_label({})).to be_nil
    end
  end

  context 'when using Alma' do
    before do
      allow(Rails.configuration).to receive(:use_alma).and_return(true)
    end

    let(:fallback) { 'Fallback' }
    let(:without_code) { { 'library' => 'Library Name', 'location' => fallback } }
    let(:invalid_code) { { 'library' => 'Library Name', 'location' => fallback, 'location_code' => 'invalid' } }
    let(:valid_code) { { 'library' => 'Library Name', 'location' => fallback, 'location_code' => 'firestone$clas' } }

    it 'returns holding location label when location code lookup successful' do
      stub_alma_holdings
      expect(holding_location_label(valid_code)).to eq('Firestone Library - Classics Collection')
    end
    it 'returns holding location value when location code lookup fails' do
      stub_request(:get, "#{ENV['bibdata_base']}/locations/holding_locations.json")
        .to_return(status: 500,
                   body: '')
      expect(holding_location_label(invalid_code)).to eq('Library Name - Fallback')
    end
    it 'returns holding location value when no location code' do
      expect(holding_location_label(without_code)).to eq('Library Name - Fallback')
    end
    it 'returns nil when no location code or holding location value' do
      expect(holding_location_label({})).to be_nil # -
    end
  end

  describe '#aeon_location?' do
    let(:loc) { { aeon_location: true } }

    it 'returns the location aeon_location attribute value' do
      expect(aeon_location?(loc)).to eq true
    end
    it 'returns false when nil location is passed to function' do
      expect(aeon_location?(nil)).to eq false
    end
  end

  describe '#current_year' do
    it 'returns the current year' do
      expect(current_year).to eq DateTime.now.year
    end
  end
end
