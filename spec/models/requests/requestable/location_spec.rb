# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Requestable::Location, requests: true do
  describe '#library_label' do
    it 'takes the library label from the provided bibdata location hash' do
      location = described_class.new(JSON.parse('{"label":"English Theses","code":"annex$set","aeon_location":false,"recap_electronic_delivery_location":false,"open":false,"requestable":true,"always_requestable":false,"circulates":true,"remote_storage":"","fulfillment_unit":"Closed","library":{"label":"Forrestal Annex","code":"annex","order":0},"holding_library":null,"delivery_locations":[]}'))
      expect(location.library_label).to eq('Forrestal Annex')
    end
  end
end
