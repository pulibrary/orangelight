# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :request_without_facet_queries do
  match do |actual|
    actual[:params].keys.exclude? 'facet.query'
  end
end

describe 'Orangelight advanced search', type: :request, advanced_search: true do
  before do
    stub_holding_locations
  end

  it 'renders the advanced search form' do
    get '/advanced?f[subject_facet][]=United+Nations-Decision+making'
    expect(response.status).to eq(200)
  end

  it 'does not send complex facet queries to solr when rendering advanced search form' do
    # rubocop:disable RSpec/AnyInstance
    expect_any_instance_of(RSolr::Client).to receive(:send_and_receive)
      .with('select', request_without_facet_queries)
      .once
      .and_call_original
    # rubocop:enable RSpec/AnyInstance

    get '/advanced'
  end
end
