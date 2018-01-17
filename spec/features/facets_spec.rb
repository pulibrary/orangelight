require 'rails_helper'

describe 'Facets' do
  before { stub_holding_locations }

  context 'with facets rendered' do
    it 'renders only a subset of all the facets on the homepage' do
      visit '/catalog'
      home_facets = page.all('.facet_limit').length
      visit '/catalog?search_field=all_fields'
      search_facets = page.all('.facet_limit').length
      expect(home_facets).to be < search_facets
    end

    it 'renders accessible facets' do
      visit '/catalog'
      expect(page).to have_selector '.facet-values .icon[aria-hidden="true"]', minimum: 10
    end
  end

  context 'with advanced limits' do
    it 'will render when clicked from the record' do
      visit  '/catalog/3'
      click_link 'Advanced Search'
      click_link I18n.t('blacklight_advanced_search.form.start_over')
    end
  end

  context 'advanced search only facets' do
    it 'will hide facets not configured for advanced search display' do
      visit '/catalog/?f[format][]=Book'
      expect(page.all('.blacklight-advanced_location_s').length).to eq 0
      expect(page.all('.blacklight-location').length).to eq 1
      click_link I18n.t('blacklight.search.edit_search')
      expect(page.all('#location').length).to eq 0
      expect(page.all('#advanced_location_s').length).to eq 1
    end
  end
end
