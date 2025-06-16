# frozen_string_literal: true
require_relative 'smoke_spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Deployed environment', :staging_test do
  let(:host) { 'catalog-staging.princeton.edu' }
  let(:path) { nil }
  let(:query) { nil }
  let(:uri) { URI::HTTPS.build(host:, path:, query:) }

  describe 'home page' do
    it 'has facets' do
      visit uri
      expect(page).to have_selector("#facet-access_facet")
      within("#facet-access_facet") do
        expect(page).to have_link("In the Library")
      end
    end
  end
  describe 'search' do
    let(:path) { '/catalog' }
    let(:query) { 'search_field=all_fields&q=potato' }
    it 'can be performed' do
      visit uri
      expect(page).to have_link('Edit search')
      expect(page).to have_content("You searched for:")
      expect(page).to have_content("Potato")
    end
  end
end
# rubocop:enable RSpec/DescribeClass
