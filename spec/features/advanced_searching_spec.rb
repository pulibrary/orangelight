# frozen_string_literal: true

require 'rails_helper'

describe 'advanced searching' do
  before do
    stub_holding_locations
  end

  it 'renders an accessible button for starting over the search' do
    visit '/advanced'
    expect(page).to have_selector '.icon-refresh[aria-hidden="true"]'
  end

  it 'provides labels to form elements' do
    visit '/advanced'
    expect(page).to have_selector('label', exact_text: 'Options for advanced search')
    expect(page).to have_selector('label', exact_text: 'Advanced search terms')
    expect(page).to have_selector('label', exact_text: 'Options for advanced search - second parameter')
    expect(page).to have_selector('label', exact_text: 'Advanced search terms - second parameter')
    expect(page).to have_selector('label', exact_text: 'Options for advanced search - third parameter')
    expect(page).to have_selector('label', exact_text: 'Advanced search terms - third parameter')
    expect(page).to have_selector('label', exact_text: 'Publication date range (starting year)')
    expect(page).to have_selector('label', exact_text: 'Publication date range (ending year)')
  end

  it 'allows searching by format', js: true do
    visit '/advanced'
    expect(page).to have_selector('label', exact_text: 'Format')
    format_button = find_button('Type or select formats')
    format_button.click
    drop_down = format_button.sibling(".dropdown-menu")
    expect(drop_down).to have_content("Musical score")
    expect(drop_down).to have_content("Senior thesis")
    drop_down.find("input").fill_in(with: "co")
    expect(drop_down).to have_content("Musical score")
    expect(drop_down).to have_content("Coin")
    expect(drop_down).not_to have_content("Senior thesis")
    page.find('li', text: 'Musical score').click
    click_button("advanced-search-submit")
    expect(page).to have_content("Il secondo libro de madregali a cinque voci / di Giaches de Wert.")
    expect(page).not_to have_content("Огонек : роман")
  end

  context 'with a numismatics advanced search type' do
    it 'provides labels to numismatics form elements' do
      visit '/numismatics'
      expect(page).to have_selector('label', exact_text: 'Object Type')
      expect(page).to have_selector('label', exact_text: 'Denomination')
      expect(page).to have_selector('label', exact_text: 'Metal')
      expect(page).to have_selector('label', exact_text: 'City')
      expect(page).to have_selector('label', exact_text: 'State')
      expect(page).to have_selector('label', exact_text: 'Region')
      expect(page).to have_selector('label', exact_text: 'Ruler')
      expect(page).to have_selector('label', exact_text: 'Artist')
      expect(page).to have_selector('label', exact_text: 'Find Place')
      expect(page).to have_selector('label', exact_text: 'Year')
      expect(page).to have_selector('label', exact_text: 'Keyword')
    end
  end
end
