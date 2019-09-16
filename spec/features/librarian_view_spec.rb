# frozen_string_literal: true
require 'rails_helper'

context 'when the MARC data cannot be generated for a Solr Document' do
  it 'flashes an error message' do
    stub_test_document
    visit '/catalog/test-id/staff_view'
    expect(page).to have_content 'No MARC data found'
  end
end
