# frozen_string_literal: true

require 'rails_helper'

describe 'advanced searching', advanced_search: true do
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

  it 'allows searching by publication date', js: true do
    visit '/advanced'
    find('#range_pub_date_start_sort_begin').fill_in(with: '1990')
    find('#range_pub_date_start_sort_end').fill_in(with: '1995')
    click_button('advanced-search-submit')
    expect(page).to have_content('Aomen')
  end

  it 'can exclude terms from the search' do
    visit '/advanced'
    # defaults to keyword
    fill_in(id: 'q1', with: 'gay')
    choose(id: 'op3_NOT')
    # defaults to title
    fill_in(id: 'q3', with: 'RenoOut')
    click_button('advanced-search-submit')
    expect(page.find(".page_entries").text).to eq('1 entry found')
    expect(page).to have_content('Seeking sanctuary')
    expect(page).to have_content('Title NOT RenoOut')
    expect(page).not_to have_content('Reno Gay Press and Promotions')
  end

  context 'with the built-in advanced search form' do
    before do
      allow(Flipflop).to receive(:view_components_advanced_search?).and_return(true)
      allow(Flipflop).to receive(:json_query_dsl?).and_return(true)
      visit '/advanced'
    end

    it 'renders an accessible button for starting over the search' do
      expect(page).to have_selector '.icon-refresh[aria-hidden="true"]'
    end

    it 'has the correct limit text' do
      expect(page).to have_content('Limit results by')
    end

    it 'has drop-downs for search fields' do
      search_fields = page.find_all('.search-field')
      expect(search_fields.size).to eq(4)
    end

    it 'can run a search' do
      # This passes locally with an older Solr LuceneMatchVersion
      # And when run only within context.
      pending('Flipflop in controller fix')
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      click_button('advanced-search-submit')
      expect(page.find(".page_entries").text).to eq('1 - 2 of 2')
      expect(page).to have_content('Seeking sanctuary')
      expect(page).to have_content('RenoOut')
    end

    it 'can exclude terms from the search', js: false do
      # This passes locally with an older Solr LuceneMatchVersion
      # And when run only within context.
      pending('Flipflop in controller fix')
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      choose(id: 'clause_2_op_must_not')
      # defaults to title
      fill_in(id: 'clause_2_query', with: 'RenoOut')
      click_button('advanced-search-submit')
      expect(page.find(".page_entries").text).to eq('1 entry found')
      expect(page).to have_content('Seeking sanctuary')
      expect(page).not_to have_content('Reno Gay Press and Promotions')
    end

    it 'shows constraint-value on search results page' do
      pending('Display constraint-value on search result page from built-in advanced search')
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      choose(id: 'clause_2_op_must_not')
      # defaults to title
      fill_in(id: 'clause_2_query', with: 'RenoOut')
      click_button('advanced-search-submit')
      expect(page).to have_content('Title NOT RenoOut')
    end
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
