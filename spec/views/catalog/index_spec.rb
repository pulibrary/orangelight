# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/index' do
  before do
    stub_holding_locations
  end

  describe 'landing page' do
    it 'does not contain the same DOM ID twice' do
      visit '/catalog'
      expect(page).to have_selector('#bookmarks_nav', count: 1)
    end
    it 'contains a valid link to the e-journals' do
      visit '/'
      link = find_link('E-journal titles')
      expect(link[:href]).to eq('/?f%5Baccess_facet%5D%5B%5D=Online&f%5Bformat%5D%5B%5D=Journal')
    end

    it 'includes #main-flashes' do
      visit '/'
      expect(page).to have_selector('#main-flashes', count: 1)
    end

    it 'has links to the statement on language in description' do
      visit '/'
      language_link = find_link('Statement on language in description')
      read_more_language_link = find_link('Read more...', href: 'https://library.princeton.edu/about/languagestatement')
      links = [language_link, read_more_language_link]
      links.each do |link|
        expect(link[:target]).to be nil
        expect(link[:title]).to be nil
        expect(link[:'aria-label']).to eq('Read more about Statement on language in description')
      end
    end

    it 'has links to the PUL open dataset description' do
      visit '/'
      open_dataset_link = find_link('PUL Open Dataset')
      read_more_dataset_link = find_link('Read more...', href: '/dataset')
      links = [open_dataset_link, read_more_dataset_link]
      links.each do |link|
        expect(link[:target]).to be nil
        expect(link[:title]).to be nil
        expect(link[:'aria-label']).to eq('Read more about PUL Open Dataset')
      end
    end
  end

  describe 'index fields json only fields (show: false)' do
    it 'do not display in html view' do
      visit '/catalog?f%5Bformat%5D%5B%5D=Map'
      expect(page).to have_selector('.blacklight-holdings')
      expect(page).not_to have_selector('.blacklight-holdings_1display')
    end
    it 'are included in json view' do
      visit '/catalog.json?f%5Bformat%5D%5B%5D=Map'
      response = JSON.parse(page.body)
      expect(response['data'][0]['attributes'].keys).to include('title_display', 'holdings_1display')
    end
  end

  describe 'search results' do
    it '<ul> elements contain only <li>, <script>, or <template>' do
      visit '/catalog?q=korea'
      lists = page.all('ul')
      child_tags = lists.map { |list| list.find_all(:xpath, './*').map(&:tag_name) }.flatten.uniq
      invalid_child_tags = child_tags.delete_if { |tag| %(li script template).include? tag }
      expect(invalid_child_tags).to be_empty
    end
  end

  describe 'advanced search' do
    it 'inclusive facets display when applied' do
      visit '/catalog?f_inclusive%5Bformat%5D%5B%5D=Audio&search_field=advanced'
      expect(page).to have_selector('.blacklight-format.facet-limit-active')
      expect(page).to have_selector('.advanced_facet_limit')
    end
  end
end
