# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#render_location_code' do
    before { stub_holding_locations }

    it 'returns value when value is not a valid location code' do
      value = 'blah'
      expect(render_location_code(value)).to eq value
    end

    it 'renders full location when value is a valid location code' do
      expect(render_location_code('firestone$clas')).to eq('firestone$clas: Firestone Library - Classics Collection')
    end

    it 'can handle an array' do
      expect(render_location_code(['firestone$clas'])).to eq('firestone$clas: Firestone Library - Classics Collection')
      expect(render_location_code(['firestone$clas', 'blah'])).to eq(['firestone$clas: Firestone Library - Classics Collection', 'blah'])
    end

    it 'can handle a hash' do
      expect(render_location_code({ "0" => "Mendel Music Library", "1" => "Online" })).to match_array(["Mendel Music Library", "Online"])
    end

    it 'can handle a hash with indifferent access' do
      location_hash = ActiveSupport::HashWithIndifferentAccess.new
      location_hash["0"] = "Mendel Music Library"
      location_hash["1"] = "Online"
      expect(render_location_code(location_hash)).to match_array(["Mendel Music Library", "Online"])
    end
  end

  describe '#holding_location_label' do
    let(:fallback) { 'Fallback' }
    let(:without_code) { { 'library' => 'Library Name', 'location' => fallback } }
    let(:invalid_code) { { 'library' => 'Library Name', 'location' => fallback, 'location_code' => 'invalid' } }
    let(:valid_code) { { 'library' => 'Library Name', 'location' => fallback, 'location_code' => 'firestone$aas' } }
    let(:code_location_blank) { { 'library' => 'Library Name', 'location' => '', 'location_code' => 'firestone$aas' } }

    it 'returns holding location label when location code lookup successful' do
      stub_holding_locations
      expect(holding_location_label(valid_code)).to eq('Firestone Library - African American Studies Reading Room')
    end
    context 'when location code lookup fails' do
      before do
        stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations.json")
          .to_return(status: 500,
                     body: '')
      end
      it 'returns holding location value' do
        expect(holding_location_label(invalid_code)).to eq('Library Name - Fallback')
      end
      it 'does not include a trailing dash when indexed location is blank' do
        expect(holding_location_label(code_location_blank)).to eq('Library Name')
      end
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
