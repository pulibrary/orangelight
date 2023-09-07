# frozen_string_literal: true
require 'rails_helper'

context 'when the MARC data cannot be generated for a Solr Document' do
  before do
    allow_any_instance_of(CatalogController).to receive(:agent_is_crawler?).and_return(false)
  end
  it 'flashes an error message' do
    stub_test_document
    visit '/catalog/test-id/staff_view'
    expect(page).to have_content 'No MARC data found'
  end
end
