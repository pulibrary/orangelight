# frozen_string_literal: true

require 'rails_helper'

describe 'Orangelight advanced search', type: :request do
  before do
    stub_holding_locations
  end

  it 'redirects search requests to the catalog search' do
    get '/advanced?f[subject_facet][]=United+Nations-Decision+making&id=3681146&page=1&per_page=20'
    expect(response.status).to eq(302)
    expect(response).to redirect_to('/')
  end
  it 'renders the advanced search form' do
    get '/advanced?f[subject_facet][]=United+Nations-Decision+making'
    expect(response.status).to eq(200)
  end
end
