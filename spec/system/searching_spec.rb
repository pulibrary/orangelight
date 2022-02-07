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

  it 'renders an accessible link to the stack map' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.fa-map-marker[aria-hidden="true"]'
  end

  it 'renders an accessible icon for item icons' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.blacklight-format .icon[aria-hidden="true"]'
  end

  # We don't have the on-site icon at the moment. It appears as available. We might add it back in the future.
  context 'with items which are from aeon locations' do
    it 'renders an accessible warning icon for requesting an item in a reading room' do
      visit '/catalog?f%5Blocation%5D%5B%5D=Mudd+Manuscript+Library'
      expect(page).to have_selector 'span.icon-warning.icon-request-reading-room[aria-hidden="true"]'
    end
  end

  context 'Availability: On-site by request' do
    it 'On-site label is green' do
      visit '/?f%5Baccess_facet%5D%5B%5D=In+the+Library&q=id%3Adsp*&search_field=all_fields'
      expect(page).to have_selector '#documents > article.document.blacklight-senior-thesis.document-position-0 > div > div.record-wrapper > ul > li.blacklight-holdings > ul > li:nth-child(1) > span.availability-icon.badge.badge-success'
    end
  end

  context 'chosen selected values' do
    it 'removes a chosen selected value' do
      visit '/catalog?utf8=%E2%9C%93&f1=all_fields&q3=&f_inclusive%5Bformat%5D%5B%5D=Journal&search_field=advanced&commit=Search'
      expect(page).to have_link 'Edit search'
      page.find(:xpath, '//*[@id="editSearchLink"]').click
      expect(current_url).to include 'f_inclusive%5Bformat%5D%5B%5D=Journal'
      page.find(:xpath, '//select[@id="format"]/option[4]').unselect_option
      page.find(:xpath, '//*[@id="advanced-search-submit"]').click
      expect(current_url).not_to include 'f_inclusive%5Bformat%5D%5B%5D=Journal'
    end
  end

  context 'with chosen selected numismatic values' do
    it 'removes a chosen selected numismatic value' do
      visit '/catalog?f%5Bformat%5D%5B%5D=Coin&advanced_type=numismatics&f_inclusive%5Bissue_city_s%5D%5B%5D=Tyre&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&f1=all_fields&q1=&sort=score+desc%2C+pub_date_start_sort+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
      expect(page).to have_link 'Edit search'
      page.find(:xpath, '//*[@id="editSearchLink"]').click
      expect(current_url).to include 'numismatics?'
      expect(current_url).to include 'f_inclusive%5Bissue_city_s%5D%5B%5D=Tyre'
      page.find(:xpath, '//select[@id="issue_city_s"]/option[1]').unselect_option
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

  context 'when a request parameter contains a space' do
    it 'displays an error message' do
      visit '/catalog/range_limit?%20%20%20%20range_end=1990&%20%20%20%20range_field=pub_date_start_sort&%20%20%20%20range_start=1981'
      expect { page }.not_to raise_error
      expect(page).to have_content(/.*For help, please email.*start over.*/)
    end
  end
  context 'with an invalid field list parameter in the advanced search' do
    it 'will return results without an error' do
      visit '/catalog?q1=NSF%20Series&search_field=advanced&f1=in_series2121121121212.1'
      expect { page }.not_to raise_error
      expect(page).to have_content 'No results found for your search'
    end
  end
  context 'when searching with an invalid facet parameter' do
    it 'returns a 400 response, displays an error message, and logs the error' do
      allow(Rails.logger).to receive(:error)

      visit '/catalog?q=test&f=1'
      expect { page }.not_to raise_error
      expect(page.status_code).to eq 400
      expect(page).to have_content(/.*For help, please email.*start over.*/)
      expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request: Invalid facet parameter passed: 1/)
    end
  end
  context 'when searching for faceted titles with UTF-8 characters' do
    it 'returns a 400 response, displays an error message, and logs the error' do
      allow(Rails.logger).to receive(:error)

      visit "/catalog?q=&f[author_s]=#{CGI.escape('汪精衛, 1883-1944')}"
      expect { page }.not_to raise_error
      expect(page.status_code).to eq 400
      expect(page).to have_content(/.*For help, please email.*start over.*/)
      expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request: Facet field author_s has a scalar value 汪精衛, 1883-1944/)
    end
  end
end
