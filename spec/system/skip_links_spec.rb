# frozen_string_literal: true

require 'rails_helper'

describe 'skip links', type: :system do
  before do
    stub_holding_locations
  end

  describe 'on the search results page' do
    context 'when no search results' do
      it 'only has two skip links' do
        visit '/catalog?q=Uec4rvei7Aoxa'
        expect(page).to have_selector('#skip-link a', count: 2, visible: false)
      end
    end

    context 'when there are search results' do
      it 'includes the number of search results in the skip link text' do
        visit '/catalog?f[format][]=Senior+thesis'
        expect(page).to have_selector('#skip-link a', text: 'Skip to result 1 of 9', visible: false)
      end
    end

    context 'when no basic search bar' do
      it 'numismatics page has only one skip link' do
        visit '/numismatics'
        expect(page).to have_selector('#skip-link a', count: 1, visible: false)
      end
      it 'advanced search page has only one skip link' do
        visit '/advanced'
        expect(page).to have_selector('#skip-link a', count: 1, visible: false)
      end
      context 'with the new advanced search' do
        before do
          allow(Flipflop).to receive(:view_components_advanced_search?).and_return(true)
          allow(Flipflop).to receive(:json_query_dsl?).and_return(true)
        end
        it 'advanced search page has only one skip link' do
          visit '/advanced'
          expect(page).to have_selector('#skip-link a', count: 1, visible: false)
        end
      end
    end
  end
end
