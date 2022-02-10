# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/index' do
  before do
    stub_holding_locations
  end

  describe 'landing page' do
    it 'does not contain the same DOM ID twice' do
      visit '/catalog'
      expect(page).to have_selector('#bookmarks_nav', count: 1)
    end
  end

  describe 'index fields json only fields (show: false)' do
    it 'do not display in html view' do
      visit '/catalog?f%5Bformat%5D%5B%5D=Map'
      expect(page).to have_selector('.blacklight-holdings')
      expect(page).not_to have_selector('.blacklight-holdings_1display')
    end
    it 'are included in json view' do
      visit '/catalog.json?f%5Bformat%5D%5B%5D=Map'
      response = JSON.parse(page.body)
      expect(response['data'][0]['attributes'].keys).to include('title_display', 'holdings_1display')
    end
  end

  describe 'advanced search' do
    it 'inclusive facets display when applied' do
      visit '/catalog?f_inclusive%5Bformat%5D%5B%5D=Audio&search_field=advanced'
      expect(page).to have_selector('.blacklight-format.facet_limit-active')
      expect(page).to have_selector('.advanced_facet_limit')
    end
  end
end
