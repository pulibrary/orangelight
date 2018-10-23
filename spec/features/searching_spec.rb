# frozen_string_literal: true

require 'rails_helper'

describe 'searching' do
  before do
    stub_holding_locations
  end

  it 'renders an accessible search button' do
    visit '/catalog'
    expect(page).to have_selector '.glyphicon-search[aria-hidden="true"]'
  end

  it 'renders an accessible link to the stack map' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.glyphicon-map-marker[aria-hidden="true"]'
  end

  it 'renders an accessible icon for item icons' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.blacklight-format .icon[aria-hidden="true"]'
  end

  context 'with items which are from aeon locations' do
    it 'renders an accessible icon for requesting an item on-site' do
      visit '/catalog?f%5Bformat%5D%5B%5D=Journal'
      expect(page).to have_selector '.icon-request-reading-room[aria-hidden="true"]'
    end
  end

  context 'Availability: On-site by request' do
    it 'On-site label is green' do
      visit '/?f%5Baccess_facet%5D%5B%5D=In+the+Library&q=id%3Adsp*&search_field=all_fields'
      expect(page).to have_selector '#documents > div.document.blacklight-senior-thesis.document-position-0 > div > div.record-wrapper > ul > li.blacklight-holdings > ul > li:nth-child(1) > span.availability-icon.label.label-success'
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

  context 'raise flash error if BadRequest', js: true do
    it 'will display a flash message if there is a BadRequest error' do
      visit '/catalog/range_limit?%20%20%20%20range_end=1990&%20%20%20%20range_field=pub_date_start_sort&%20%20%20%20range_start=1981'
      expect { page }.not_to raise_error
      expect(page).to have_current_path('/')
      expect(page).to have_content 'This is not a valid request.'
    end
  end

  context 'with an invalid field list parameter in the advanced search' do
    it 'will return results without an error' do
      visit '/catalog?q1=NSF%20Series&search_field=advanced&f1=in_series2121121121212.1'
      expect { page }.not_to raise_error
      expect(page).to have_content 'No results found for your search'
    end
  end
end
