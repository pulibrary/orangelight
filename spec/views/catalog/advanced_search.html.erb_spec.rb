# frozen_string_literal: true

require 'rails_helper'
require 'byebug'

RSpec.describe 'catalog/index' do
  before do
    stub_holding_locations
  end

  describe 'language facet' do
    before do
      # Needed since we cache the facets to help the page load faster
      Rails.cache.clear
    end
    context 'with an empty search' do
      before do
        visit '/advanced'
      end
      it 'has the full list of languages', js: true do
        ul = page.find('#language_facet-list', visible: false)
        language_list_elements = ul.all('li', visible: false)
        expect(language_list_elements.size).to be > 10
      end
    end
    context 'with an edited search' do
      before do
        visit '/advanced?q=a&search_field=all_fields'
      end
      it 'has the full list of languages', js: true do
        ul = page.find('#language_facet-list', visible: false)
        language_list_elements = ul.all('li', visible: false)
        expect(language_list_elements.size).to be > 10
      end
    end
    context 'with regular search results' do
      before do
        visit '/catalog?search_field=all_fields&q=a'
      end
      it 'still only shows ten languages in the sidebar' do
        within '#facet-language_facet' do
          language_list_elements = page.find_all('li')
          expect(language_list_elements.size).to eq(10)
        end
      end
    end
  end
end
