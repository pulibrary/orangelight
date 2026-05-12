# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define :be_off_screen do
  match do |selector|
    # Check to see if the element is clipped as in bootstrap visually hidden
    page.execute_script("return window.getComputedStyle(document.querySelector('#{selector}')).clip?.includes('rect(0')")
  end
end

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

      it 'makes the skip link visible when focusing', js: true do
        visit '/catalog?q=Uec4rvei7Aoxa'
        expect('#skip-link a').to be_off_screen
        page.execute_script('document.querySelector("#skip-link a").focus()')
        expect('#skip-link a').not_to be_off_screen
      end
    end

    context 'when there are search results' do
      it 'includes the number of search results in the skip link text' do
        visit '/catalog?f[format][]=Senior+thesis'
        expect(page).to have_selector('#skip-link a', text: 'Skip to result 1 of 9', visible: false)
      end
    end

    context 'when no basic search bar', advanced_search: true do
      it 'numismatics page has only one skip link' do
        visit '/numismatics'
        expect(page).to have_selector('#skip-link a', count: 1, visible: false)
      end
      it 'advanced search page has only one skip link' do
        visit '/advanced'
        expect(page).to have_selector('#skip-link a', count: 1, visible: false)
      end
    end
  end
end
