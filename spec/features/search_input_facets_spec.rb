# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'clicking facet limits with values in the search bar' do
  before do
    stub_holding_locations
  end

  context 'with the old advanced search' do
    before do
      allow(Flipflop).to receive(:json_query_dsl?).and_return(false)
    end
    # test 1
    it 'includes search input in result, url is escaped', js: true do
      visit '/catalog'
      select('Title starts with', from: 'search_field')
      fill_in('Search...', with: 'The & this')
      click_link 'In the Library'
      expect(current_url).to include('q=The%20%26%20this', 'search_field=left_anchor')
    end
    # test 2
    it 'only includes the url parameters once when query is unchanged', js: true do
      visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
      within '#facet-format' do
        click_link 'Book'
      end
      expect(current_url.scan(/q=The/).size).to eq 1
    end
    # test 3
    it 'updates url parameters if search input is updated', js: true do
      visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
      fill_in('Search...', with: 'next')
      within '#facet-format' do
        click_link 'Book'
      end
      expect(current_url).not_to include('q=The')
      expect(current_url).to include('q=next')
    end
  end
  context 'with the json query dsl' do
    before do
      allow(Flipflop).to receive(:json_query_dsl?).and_return(true)
    end
    context 'when the view component-based advanced search is on', advanced_search: true do
      before do
        allow(Flipflop).to receive(:view_components_advanced_search?).and_return(true)
      end
      it 'includes search input in result, url is escaped', js: true do
        visit '/advanced'
        select('Title starts with', from: 'clause_0_field')
        fill_in(id: 'clause_0_query', with: 'the')
        click_button 'Search'
        expect(page).to have_content('The senses : a comprehensive reference.')
      end
    end
    # test 1
    it 'includes search input in result, url is escaped', js: true do
      visit '/catalog'
      select('Title starts with', from: 'search_field')
      fill_in('Search...', with: 'The & this')
      click_link 'In the Library'
      expect(current_url).to include('q=The%20%26%20this', 'search_field=left_anchor')
    end
    # test 2
    it 'only includes the url parameters once when query is unchanged', js: true do
      visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
      within '#facet-format' do
        click_link 'Book'
      end
      expect(current_url.scan(/q=The/).size).to eq 1
    end
    # test 3
    it 'updates url parameters if search input is updated', js: true do
      visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
      fill_in('Search...', with: 'next')
      within '#facet-format' do
        click_link 'Book'
      end
      expect(current_url).not_to include('q=The')
      expect(current_url).to include('q=next')
    end
  end
end
