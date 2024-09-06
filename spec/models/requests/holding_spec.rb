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
end
