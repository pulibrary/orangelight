# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Holding, requests: true do
  describe '#holding_data' do
    it 'returns a hash with indifferent access of MFHD data for a special collections book' do
      holding = described_class.new(
        mfhd_id: "22654362360006421",
        holding_data: JSON.parse('{"location_code":"rare$ga","location":"Graphic Arts Collection","library":"Special Collections","call_number":"2012-0145Q","call_number_browse":"2012-0145Q","items":[{"holding_id":"22654362360006421","id":"23654362330006421","status_at_load":"1","barcode":"32101051826913","copy_number":"1"}]}')
      )
      expect(holding.holding_data['location_code']).to eq('rare$ga')
      expect(holding.holding_data[:call_number_browse]).to eq('2012-0145Q')
    end
    it 'returns an empty hash when no data is available' do
      holding = described_class.new(
        mfhd_id: "22654362360006421",
        holding_data: nil
      )
      expect(holding.holding_data).to eq({})
      expect(holding.holding_data['location_code']).to be_nil
    end
  end
  describe '#to_h' do
    it 'returns a hash with the mfhd_id as the key' do
      holding = described_class.new(
        mfhd_id: "22654362360006421",
        holding_data: JSON.parse('{"location_code":"rare$ga","location":"Graphic Arts Collection","library":"Special Collections","call_number":"2012-0145Q","call_number_browse":"2012-0145Q","items":[{"holding_id":"22654362360006421","id":"23654362330006421","status_at_load":"1","barcode":"32101051826913","copy_number":"1"}]}')
      )
      expect(holding.to_h).to eq({
                                   "22654362360006421" => { "location_code" => "rare$ga", "location" => "Graphic Arts Collection", "library" => "Special Collections", "call_number" => "2012-0145Q", "call_number_browse" => "2012-0145Q", "items" => [{ "holding_id" => "22654362360006421", "id" => "23654362330006421", "status_at_load" => "1", "barcode" => "32101051826913", "copy_number" => "1" }] }
                                 })
    end
    it 'can access the data with a symbol key' do
      holding = described_class.new(
        mfhd_id: "22654362360006421",
        holding_data: JSON.parse('{"location_code":"rare$ga","location":"Graphic Arts Collection","library":"Special Collections","call_number":"2012-0145Q","call_number_browse":"2012-0145Q","items":[{"holding_id":"22654362360006421","id":"23654362330006421","status_at_load":"1","barcode":"32101051826913","copy_number":"1"}]}')
      )
      expect(holding.to_h[:'22654362360006421'][:location_code]).to eq 'rare$ga'
    end
    it 'can access the data with a string key' do
      holding = described_class.new(
        mfhd_id: "22654362360006421",
        holding_data: JSON.parse('{"location_code":"rare$ga","location":"Graphic Arts Collection","library":"Special Collections","call_number":"2012-0145Q","call_number_browse":"2012-0145Q","items":[{"holding_id":"22654362360006421","id":"23654362330006421","status_at_load":"1","barcode":"32101051826913","copy_number":"1"}]}')
      )
      expect(holding.to_h['22654362360006421']['location_code']).to eq 'rare$ga'
    end
  end
  describe '#full_location_name' do
    it 'includes the library and location name' do
      holding = described_class.new(
        mfhd_id: "22749747440006421",
        holding_data: JSON.parse('{"location_code":"firestone$stacks","location":"Stacks","library":"Firestone Library","call_number":"TX795 .W45 2011","call_number_browse":"TX795 .W45 2011","items":[{"holding_id":"22749747440006421","id":"23749747430006421","status_at_load":"1","barcode":"32101083249613","copy_number":"1"}]}')
      )
      expect(holding.full_location_name).to eq 'Firestone Library - Stacks'
    end

    it 'incorporates current_library and current_location if present' do
      holding = described_class.new(
        mfhd_id: "lewis$res",
        holding_data: JSON.parse('{"location_code":"lewis$res","current_location":"Course Reserve","current_library":"Lewis Library","call_number":"HQ767.9 .S534 2020","call_number_browse":"HQ767.9 .S534 2020","items":[{"holding_id":"22543249720006421","id":"23543249710006421","status_at_load":"0","barcode":"32101112870454","copy_number":"1"},{"holding_id":"22543249640006421","id":"23543249630006421","status_at_load":"0","barcode":"32101092796398","copy_number":"4"},{"holding_id":"22543249660006421","id":"23543249650006421","status_at_load":"0","barcode":"32101092796380","copy_number":"3"},{"holding_id":"22543249700006421","id":"23543249690006421","status_at_load":"0","barcode":"32101102527726","copy_number":"2"}]}')
      )
      expect(holding.full_location_name).to eq 'Lewis Library - Course Reserve'
    end

    it 'does not include the hyphen if location name is empty' do
      holding = described_class.new(
        mfhd_id: "22749747440006421",
        holding_data: JSON.parse('{"location_code":"eastasian$cjk","location":"","library":"East Asian Library","call_number":"DS747.45 .S673 2025"}')
      )
      expect(holding.full_location_name).to eq 'East Asian Library'
    end

    it 'does not repeat the library name if it is also included in the location name' do
      holding = described_class.new(
        mfhd_id: "22749747440006421",
        holding_data: JSON.parse('{"location_code":"lewis$serial","location":"Lewis Library - Serials (Off-Site)","library":"Lewis Library","call_number":"TX795 .W45 2011","call_number_browse":"TX795 .W45 2011","items":[{"holding_id":"22749747440006421","id":"23749747430006421","status_at_load":"1","barcode":"32101083249613","copy_number":"1"}]}')
      )
      expect(holding.full_location_name).to eq 'Lewis Library - Serials (Off-Site)'
    end
  end
end
