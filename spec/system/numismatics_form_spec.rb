# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Numismatics search form', advanced_search: true do
  before do
    stub_holding_locations
  end

  it 'does not display the basic search form' do
    visit '/numismatics'
    expect(page).not_to have_selector('.search-query-form')
  end
  it 'can run a search', js: true do
    visit '/numismatics'
    fill_in 'issue_denomination_s', with: 'she'
    find('li', text: /shekel/).click
    click_button('advanced-search-submit')
    expect(page.find(".page_entries").text).to eq('1 entry found')
    expect(page).to have_content('Coin: 1167')
  end
  it 'can click the drop-down caret', js: true do
    visit '/numismatics'
    first_facet = page.first('.advanced-search-facet')
    within(first_facet) do
      page.find('span').click
      expect(page).to have_content('coin (3)')
    end
  end
  it 'can use keyboard navigation', js: true do
    visit '/numismatics'
    # Get to the "Denomination" dropdown
    10.times do
      page.send_keys(:tab)
    end
    page.send_keys(:down)
    expect(page).to have_content('shekel')
  end
end
