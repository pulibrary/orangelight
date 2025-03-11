# frozen_string_literal: true

require 'rails_helper'

describe 'advanced searching', advanced_search: true do
  before do
    stub_holding_locations
  end

  it 'does not have a basic search bar' do
    visit '/advanced'
    expect(page).not_to have_selector('.search-query-form')
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
    expect(page).to have_selector('label', exact_text: 'Publication year')
    expect(page).to have_selector('label', exact_text: 'Begin')
    expect(page).to have_selector('label', exact_text: 'End')
  end

  it 'allows searching by format', js: true do
    visit '/advanced'
    expect(page).to have_selector('label', exact_text: 'Format')
    format_input = find_field('format')
    format_input.click
    drop_down = format_input.sibling(".dropdown-menu")
    expect(drop_down).to have_content("Musical score")
    expect(drop_down).to have_content("Senior thesis")
    format_input.fill_in(with: "co")
    expect(drop_down).to have_content("Musical score")
    expect(drop_down).to have_content("Coin")
    expect(drop_down).not_to have_content("Senior thesis")
    page.find('li', text: 'Musical score').click
    click_button("advanced-search-submit")
    expect(page).to have_content("Il secondo libro de madregali a cinque voci / di Giaches de Wert.")
    expect(page).not_to have_content("Огонек : роман")
  end

  it 'allows searching by publication place', js: true do
    visit '/advanced'
    expect(page).to have_selector('label', exact_text: 'Place of publication')
    publication_place_input = find_field('publication_place_facet')
    publication_place_input.click
    drop_down = publication_place_input.sibling(".dropdown-menu")
    expect(drop_down).to have_content("Russia (Federation)")
    publication_place_input.fill_in(with: "sy")
    expect(drop_down).to have_content("Syria")
  end

  it 'has a pul option in the holding location select', js: true do
    visit '/advanced'
    expect(page).to have_selector('label', exact_text: 'Holding location')
    holding_location = find_field('advanced_location_s')
    holding_location.click
    drop_down = holding_location.sibling(".dropdown-menu")
    expect(drop_down).to have_content("All Princeton Holdings")
  end

  it 'allows searching by publication date', js: true do
    visit '/advanced'
    find('#range_pub_date_start_sort_begin').fill_in(with: '1990')
    find('#range_pub_date_start_sort_end').fill_in(with: '1995')
    click_button('advanced-search-submit')
    expect(page).to have_content('Aomen')
  end

  it 'allows users to use booleans within a query' do
    visit '/advanced'
    fill_in(id: 'clause_0_query', with: 'history OR abolition')
    click_button('advanced-search-submit')
    expect(page).to have_content('Themes and individuals in history')
  end

  context 'when editing the search', js: true do
    it 'shows the selected value in the combobox' do
      visit '/advanced'
      format_input = find_field('format')
      format_input.click
      page.find('li', text: 'Audio').click
      click_button("advanced-search-submit")
      click_link('Edit search')

      expect(page).to have_field('Format', with: /Audio/)
    end
  end

  context 'with the built-in advanced search form' do
    before do
      visit '/advanced'
    end

    it 'does not have a basic search bar' do
      visit '/advanced'
      expect(page).not_to have_selector('.search-query-form')
    end

    it 'has the expected facets' do
      visit '/advanced'
      expect(page.find_all('.advanced-facet-label').map(&:text)).to match_array(["Access", "Format", "Language", "Holding location", "Publication year", "Place of publication"])
    end

    it 'renders an accessible button for starting over the search' do
      expect(page).to have_selector '.icon-refresh[aria-hidden="true"]'
    end

    it 'has the correct limit text' do
      expect(page).to have_content('Limit results by')
    end

    it 'has drop-downs for search fields' do
      search_fields = page.find_all('.search-field')
      expect(search_fields.size).to eq(3)
    end

    it 'can run a search' do
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      click_button('advanced-search-submit')
      expect(page.find(".page_entries").text).to eq('1 - 2 of 2')
      expect(page).to have_content('Seeking sanctuary')
      expect(page).to have_content('RenoOut')
    end

    it 'can exclude terms from the search', js: false do
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      choose(id: 'boolean_operator2_NOT')
      # defaults to title
      fill_in(id: 'clause_2_query', with: 'RenoOut')
      click_button('advanced-search-submit')
      expect(page.find(".page_entries").text).to eq('1 entry found')
      expect(page).to have_content('Seeking sanctuary')
      expect(page).not_to have_content('Reno Gay Press and Promotions')
    end

    it 'can do a boolean OR search', js: false do
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      choose(id: 'boolean_operator1_OR')
      # defaults to title
      select('Title', from: 'clause_1_field')
      fill_in(id: 'clause_1_query', with: 'algebra')
      click_button('advanced-search-submit')
      expect(page.find(".page_entries").text).to eq('1 - 3 of 3')
      expect(page).to have_content('Seeking sanctuary')
      expect(page).to have_content('Reno Gay Press and Promotions')
      expect(page).to have_content('College algebra')
    end

    it 'shows constraint-value on search results page' do
      # defaults to keyword
      fill_in(id: 'clause_0_query', with: 'gay')
      choose(id: 'boolean_operator2_NOT')
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

  context 'when editing the search', js: true do
    it 'shows the selected value in the combobox' do
      visit '/advanced'
      format_input = find_field('format')
      format_input.click
      page.find('li', text: 'Audio').click
      click_button("advanced-search-submit")
      click_link('Edit search')

      expect(page).to have_field('Format', with: /Audio/)
    end

    it 'can do an advanced search with updated criteria' do
      visit '/advanced'
      fill_in 'clause_0_query', with: 'gay'
      click_button 'Search'
      expect(page).to have_content('Seeking sanctuary')
      click_link('Edit search')
      expect(page).to have_content('Keyword:gay')
      fill_in('clause_0_query', with: 'dance', fill_options: { clear: :backspace })
      click_button 'Search'
      expect(page).not_to have_content('Seeking sanctuary')
      expect(page).to have_content('Dancing Black')
    end
  end

  it 'can edit a facet-only search' do
    visit '/?f[subject_topic_facet][]=Manuscripts%2C+Arabic&search_field=all_fields'
    expect(page).to have_content '1 - 6 of 6'

    click_link 'Edit search'
    fill_in 'clause_0_query', with: 'literature'
    click_button 'Search'

    expect(page).to have_content '1 - 2 of 2'
    expect(page).to have_content 'المقامات'
    expect(page).to have_content 'مطول'
  end

  it 'gives different results for the series title search vs. keyword search' do
    visit '/advanced'
    select('Keyword', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'heft')
    click_button 'Search'
    expect(page).to have_content '1 - 3 of 3'

    visit '/advanced'
    select('Series title', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'heft')
    click_button 'Search'
    expect(page).to have_content '1 entry found'
  end
  it 'gives different results for the publisher search vs. keyword search' do
    visit '/advanced'
    select('Keyword', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'Center')
    click_button 'Search'
    expect(page).to have_content 'Zhong gong zhong yao li shi wen'

    visit '/advanced'
    select('Publisher', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'Center')
    click_button 'Search'
    expect(page).to have_content 'Boulder, Col. : The Center, 1978-'
    expect(page).not_to have_content 'Service Center for Chinese Publications'
  end
  it 'gives different results for the notes search vs. keyword search' do
    visit '/advanced'
    select('Keyword', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'Turkish')
    click_button 'Search'
    expect(page).to have_content 'Ahmet Kutsi Tecer sempozyum bildirileri : Sıvas 24 - 27 Nisan 2018'

    visit '/advanced'
    select('Notes', from: 'clause_0_field')
    fill_in(id: 'clause_0_query', with: 'Turkish')
    click_button 'Search'
    expect(page).not_to have_content 'Ahmet Kutsi Tecer sempozyum bildirileri : Sıvas 24 - 27 Nisan 2018'
  end
end
