# frozen_string_literal: true
require 'rails_helper'

describe 'linked records api' do
  it 'responds to a POST with json of related records' do
    post '/catalog/99124945733506421/linked_records/related_record_s'
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body).count).to eq(13)
  end
  it 'responds to invalid ID with a 400 status code' do
    post '/catalog/123/linked_records/related_record_s'
    expect(response.status).to eq(400)
  end
end
