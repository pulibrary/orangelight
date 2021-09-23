# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
  describe 'stackmap action' do
    before { stub_holding_locations }
    it 'assigns the expected instance variables with provided call number' do
      get :stackmap, params: { id: 9_222_024, loc: 'firestone$stacks', cn: 'Call number' }
      expect(assigns(:location_label)).to eq('Stacks')
      expect(assigns(:call_number)).to eq('Call number')
    end

    it 'assigns the first document call number when cn param not provided' do
      get :stackmap, params: { id: 9_222_024, loc: 'firestone$stacks' }
      expect(assigns(:call_number)).to eq('PS3566.I428 A6 2015')
    end
  end
end
