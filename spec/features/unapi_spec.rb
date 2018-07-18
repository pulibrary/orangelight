# frozen_string_literal: true

require 'rails_helper'

describe 'Unapi suport' do
  describe 'Show Page', js: true do
    before do
      stub_holding_locations
      visit '/catalog/3256177'
    end
    it 'contains an unapi reference in an abbr tag' do
      expect(page).to have_selector('.unapi-id')
      expect(page).to have_xpath("//abbr[@title='3256177']")
    end
  end

  describe 'Search Results Page', js: true do
    before do
      stub_holding_locations
      visit '/catalog?search_field=all_fields&q='
    end
    it 'contains an unapi reference for every search result' do
      expect(page.all('.unapi-id').length).to eq 20
      expect(page).to have_xpath('//abbr[@title]')
    end
  end

  describe 'RIS response' do
    before do
      visit '/catalog/3256177.ris'
    end
    it 'returns the correct mime type for RIS' do
      expect(page.response_headers['Content-Type']).to eq('application/x-research-info-systems; charset=utf-8')
    end
  end

  describe 'Un API resource' do
    before do
      visit '/unapi?id=3256177&format=ris'
    end
    it 'returns the correct mime type for RIS' do
      expect(page.response_headers['Content-Type']).to eq('application/x-research-info-systems')
    end
  end

  describe 'trap nil format' do
    before do
      stub_holding_locations
      visit 'catalog/SCSB-7935196.ris'
    end
    it 'returns the correct mime type for RIS when format is missing' do
      expect(page.status_code).to eq(200)
    end
  end
end
