# frozen_string_literal: true

require 'rails_helper'

describe 'Searching', type: :system, js: false do
  before do
    stub_holding_locations
  end

  it 'renders an accessible search button' do
    visit '/catalog'
    expect(page).to have_selector '.fa-search[aria-hidden="true"]'
  end

  context 'with highlighting feature on' do
    before do
      allow(Flipflop).to receive(:highlighting?).and_return(true)
    end
    # mark as pending until we resolve https://github.com/pulibrary/pul_solr/issues/388
    xit 'renders a title with an em tag around the search term' do
      visit '/catalog?q=black+teenagers'
      expect(page).to have_selector('#documents > article.blacklight-book.document.document-position-1 > div > div.record-wrapper > div > h3 > a > em:nth-child(2)', text: 'black')
      expect(page).to have_selector('#documents > article.blacklight-book.document.document-position-1 > div > div.record-wrapper > div > h3 > a > em:nth-child(4)', text: 'teenagers')
    end
  end
  context 'When highlighting is on and field displays in the index page' do
    before do
      allow(Flipflop).to receive(:highlighting?).and_return(true)
      allow_any_instance_of(Blacklight::Configuration::Field).to receive(:if).and_return(true)
    end
    let(:config) { Blacklight::Configuration.new }
    # mark as pending until we resolve https://github.com/pulibrary/pul_solr/issues/388
    xit 'renders lc_subject_display with an em tag around the search term' do
      visit '/catalog?q=African+American'
      expect(page).to have_selector('#documents > article.blacklight-book.document.document-position-1 > div > div.record-wrapper > ul > li:nth-child(3) > a.search-name > em:nth-child(2)', text: 'African')
      expect(page).to have_selector('#documents > article.blacklight-book.document.document-position-1 > div > div.record-wrapper > ul > li:nth-child(3) > a.search-name > em:nth-child(4)', text: 'American')
    end
  end

  it 'renders an accessible icon for item icons' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.blacklight-format .icon[aria-hidden="true"]'
  end

  context 'Availability: Available' do
    it 'On-site label is green' do
      visit '/?f%5Baccess_facet%5D%5B%5D=In+the+Library&q=id%3Adsp*&search_field=all_fields'
      expect(page).to have_selector '.green', text: 'Available'
    end
  end

  context 'chosen selected values', js: true do
    it 'removes a chosen selected value', js: true do
      visit '/catalog?utf8=%E2%9C%93&f1=all_fields&q3=&f_inclusive%5Bformat%5D%5B%5D=Journal&search_field=advanced&commit=Search'
      expect(page).to have_link 'Edit search'
      page.find(:xpath, '//*[@id="editSearchLink"]').click
      expect(current_url).to include 'f_inclusive%5Bformat%5D%5B%5D=Journal'
      page.find(:xpath, '//input[@id="format"]').click
      page.find(:xpath, '//li[contains(text(), "Journal")][not(contains(@class, "selected-item"))]').click
      page.find(:xpath, '//*[@id="advanced-search-submit"]').click
      expect(current_url).not_to include 'f_inclusive%5Bformat%5D%5B%5D=Journal'
    end
  end

  context 'with chosen selected numismatic values', js: true, advanced_search: true do
    it 'removes a chosen selected numismatic value', js: true do
      visit '/catalog?f%5Bformat%5D%5B%5D=Coin&advanced_type=numismatics&f_inclusive%5Bissue_city_s%5D%5B%5D=Tyre&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&f1=all_fields&q1=&sort=score+desc%2C+pub_date_start_sort+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
      expect(page).to have_link 'Edit search'
      page.find(:xpath, '//*[@id="editSearchLink"]').click
      expect(current_url).to include 'numismatics?'
      expect(current_url).to include 'f_inclusive%5Bissue_city_s%5D%5B%5D=Tyre'
      page.find(:xpath, '//input[@id="issue_city_s"]').click
      page.find(:xpath, '//li[contains(text(), "Tyre")][not(contains(@class, "selected-item"))]').click
      page.find(:xpath, '//*[@id="advanced-search-submit"]').click
      expect(current_url).not_to include 'f_inclusive%5Bissue_city_s%5D%5B%5D=Tyre'
    end
  end

  context 'wrong date_range_limit', js: true do
    it 'advanced search will not raise an error' do
      visit '/advanced'
      page.find(:xpath, '//*[@id="range_pub_date_start_sort_begin"]').set '2000'
      page.find(:xpath, '//*[@id="range_pub_date_start_sort_end"]').set '1900'
      expect { page.find(:xpath, '//*[@id="advanced-search-submit"]').click }.not_to raise_error
      sleep 5.seconds
      expect(page).to have_current_path('/')
      expect(page).to have_content 'The start year must be before the end year.'
    end
    it 'publication year facet will not raise an error' do
      visit '/?utf8=%E2%9C%93&search_field=all_fields&q=cats&range%5Bpub_date_start_sort%5D%5Bbegin%5D=2000&range%5Bpub_date_start_sort%5D%5Bend%5D=1900&commit=Limit'
      expect { page }.not_to raise_error
      expect(page).to have_current_path('/')
      expect(page).to have_content 'The start year must be before the end year.'
    end
  end

  context 'searching for series title from advanced search', advanced_search: true, js: true do
    it 'displays the online availability' do
      visit 'advanced'
      select('Series title', from: 'Options for advanced search')
      fill_in('Advanced search terms', with: 'SAGE research methods')
      click_on('Search')
      expect(page).to have_content('The lives of Black and Latino teenagers')
      expect(page).to have_content('SAGE Research Methods Cases Part I')
      expect(page).to have_content('SAGE research methods. Cases.')
    end
  end
  context 'when a request parameter contains a space' do
    it 'displays an error message' do
      visit '/catalog/range_limit?%20%20%20%20range_end=1990&%20%20%20%20range_field=pub_date_start_sort&%20%20%20%20range_start=1981'
      expect { page }.not_to raise_error
      expect(page).to have_content('Bad Request')
    end
  end
  context 'when searching with an invalid facet parameter' do
    it 'returns a 400 response, displays an error message, and logs the error' do
      allow(Rails.logger).to receive(:error)

      visit '/catalog?q=test&f=1'
      expect { page }.not_to raise_error
      expect(page.status_code).to eq 400
      expect(page).to have_content('Bad Request')
      expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request: Invalid facet parameter passed: 1/)
    end
  end
  context 'when searching for faceted titles with UTF-8 characters' do
    it 'returns a 400 response, displays an error message, and logs the error' do
      allow(Rails.logger).to receive(:error)

      visit "/catalog?q=&f[author_s]=#{CGI.escape('汪精衛, 1883-1944')}"
      expect { page }.not_to raise_error
      expect(page.status_code).to eq 400
      expect(page).to have_content('Bad Request')
      expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request: Facet field author_s has a scalar value 汪精衛, 1883-1944/)
    end
  end

  it 'filters using the subject_facet field' do
    visit "/catalog?f[subject_facet][]=Japan%E2%80%94History"
    expect(page).to have_content '1 entry found'
  end

  it 'allows user to successfully edit facet-only searches', advanced_search: true do
    visit "/catalog?f_inclusive[advanced_location_s][]=Firestone+Library&search_field=advanced"
    original_results_count = search_results_count
    click_link "Book"
    expect(search_results_count).to be < original_results_count
  end

  context 'when the json query dsl is on' do
    it 'can handle a boolean OR search' do
      visit '/catalog?search_field=all_fields&q=plasticity+OR+afganistan'
      expect(page).to have_content('1 - 2 of 2')
      expect(page).not_to have_content('Online')
      expect(page).to have_content('Physical')
    end
  end

  context 'with the built-in advanced search form', advanced_search: true do
    it 'can edit an existing search' do
      visit '/catalog?search_field=all_fields&q=cats'
      click_on('Edit search')
      expect(page).to have_content('Advanced Search')
      expect(page).to have_field('clause_0_query', with: 'cats')
    end

    it 'can edit an existing advanced search', advanced_search: true do
      visit '/catalog?clause[0][field]=title&clause[0][query]=plasticity'
      click_on('Edit search')
      expect(page).to have_content('Advanced Search')
      expect(page).to have_select('clause_0_field', selected: 'Title')
      expect(page).to have_field('clause_0_query', with: 'plasticity')
    end

    it 'can edit an existing title search', advanced_search: true do
      visit '/catalog?search_field=title&q=potato'
      click_on('Edit search')
      expect(page).to have_content('Advanced Search')
      expect(page).to have_select('clause_0_field', selected: 'Title')
      expect(page).to have_field('clause_0_query', with: 'potato')
    end

    # Flakey
    xit 'can add a facet to an existing search', advanced_search: true, js: true do
      visit '/advanced?q=black&search_field=all_fields'
      expect(page).to have_field('clause_0_query', with: 'black')
      access_facet = page.find('#access_facet')
      access_facet.click
      in_the_library = page.first('.dropdown-item')
      in_the_library.click
      click_on('advanced-search-submit')
      expect(page).to have_content(/Any of:\nIn the Library/)
    end

    it 'displays the online availability for a series title', advanced_search: true, js: true do
      visit 'advanced'
      select('Series title', from: 'clause_0_field')
      fill_in('clause_0_query', with: 'SAGE research methods')
      click_on('advanced-search-submit')
      expect(page).to have_content('The lives of Black and Latino teenagers')
      expect(page).to have_content('SAGE Research Methods Cases Part I')
      expect(page).to have_content('SAGE research methods. Cases.')
      expect(page).to have_content('ONLINE')
      expect(page).not_to have_content('PHYSICAL')
    end

    it 'shows facets on the advanced search results page', advanced_search: true do
      visit '/advanced'
      fill_in 'clause_0_query', with: 'robots'
      click_button 'Search'
      expect(page).to have_button('Access')
      expect(page).to have_button('Library')
      expect(page).to have_button('Format')
      expect(page).to have_button('Publication year')
      expect(page).to have_button('Language')
      expect(page).to have_content('Online')
      expect(page).to have_content('Physical')
    end
  end

  it 'can remove a search constraint' do
    visit '/catalog?search_field=all_fields&q=cats'
    constraint_close_button = page.find('.constraint.query a')
    constraint_close_button.click
    expect(page).to have_content('Limit your search')
  end

  context 'When the search result form is on' do
    before do
      allow(Flipflop).to receive(:search_result_form?).and_return(true)
    end
    it 'displays a banner' do
      visit '/catalog?search_field=all_fields&q=cats'
      expect(page).to have_content('We are working to address bias')
    end
  end

  context 'When the search result form is off' do
    before do
      allow(Flipflop).to receive(:search_result_form?).and_return(false)
    end
    it 'does not display a banner' do
      visit '/catalog?search_field=all_fields&q=cats'
      expect(page).not_to have_content('We are working to address bias')
    end
  end

  context 'with facets from the advanced search form', advanced_search: true, js: true do
    it 'keeps the facets when editing the search' do
      visit '/advanced'
      page.find('#format').click
      within('#format-list') do
        page.find('li', text: /Audio/).click
        # page.send_keys(:tab, :down, :enter)
        page.find('li', text: /Coin/).click
      end
      page.click_button('Search')
      page.click_link('Edit search')
      expect(page).to have_content('Within search')
      field_value = page.find_field('format').value
      expect(field_value).to include('Audio')
    end
  end
end

def search_results_count
  page.find(".page_entries strong:nth-child(3)").text.to_i
end
