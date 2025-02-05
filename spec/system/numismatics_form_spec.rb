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
    active_element = page.evaluate_script("document.activeElement")
    expect(active_element.text).to eq("1/2 Penny (1)")
    page.send_keys(:down)
    active_element = page.evaluate_script("document.activeElement")
    expect(active_element.text).to eq("follis (1)")
    page.send_keys(:return)
    hidden_select_options = page.find_all('#issue_denomination_s-select option', visible: false)
    expect(hidden_select_options[1]).to be_selected
    active_element = page.evaluate_script("document.activeElement")
    # It shouldn't switch focus to the entire page, but stay in the list
    expect(active_element.text).not_to include('Skip to main content')
  end
end
