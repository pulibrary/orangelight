# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/index' do
  describe 'json field rendering' do
    it 'shows raw field values and renders a json hash for 1display json string fields' do
      visit '/catalog/6773431.json'
      response = JSON.parse(page.body)
      expect(response['data']['attributes']['format']['attributes']['value']).to eq(['Map'])
      expect(response['data']['attributes']['holdings_1display']['attributes']['value'].keys).to include('6754334', '7321551')
    end
  end
end
