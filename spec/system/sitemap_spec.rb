# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dynamic Sitemap', type: :system, js: false do
  context 'index' do
    it 'renders XML with a root element' do
      pending('Re-enabling the sitemap')
      visit '/sitemap#index'
      expect(page).to have_xpath('//sitemapindex')
    end
    it 'renders at least 16 <sitemap> elements' do
      pending('Re-enabling the sitemap')
      visit blacklight_dynamic_sitemap.sitemap_index_path
      expect(page).to have_xpath('//sitemap', count: 16)
    end
  end

  context 'show' do
    it 'renders XML with a root element' do
      pending('Re-enabling the sitemap')
      visit blacklight_dynamic_sitemap.sitemap_path('1')
      expect(page).to have_xpath('//urlset')
    end
    it 'renders <url> elements' do
      pending('Re-enabling the sitemap')
      visit blacklight_dynamic_sitemap.sitemap_path('1')
      expect(page).to have_xpath('//url')
    end
  end
end
