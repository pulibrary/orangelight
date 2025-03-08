# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'facets' do
  it 'can serve a request with many facets' do
    get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29&' \
        'f[language_facet][]=French&f[publication_place_facet][]=France&f[subject_topic_facet][]=Antiquities'
    expect(response).to have_http_status :ok
  end
end
