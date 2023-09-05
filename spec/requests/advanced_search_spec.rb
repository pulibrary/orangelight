# frozen_string_literal: true

require 'rails_helper'

describe 'Orangelight advanced search', type: :request, advanced_search: true do
  before do
    stub_holding_locations
  end

  it 'renders the advanced search form' do
    get '/advanced?f[subject_facet][]=United+Nations-Decision+making'
    expect(response.status).to eq(200)
  end
end
