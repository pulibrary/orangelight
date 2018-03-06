# frozen_string_literal: true

require 'rails_helper'

describe 'browsing a catalog item', js: true do
  before do
    stub_holding_locations
  end

  it 'renders an accessible icon for citing the item' do
    visit 'catalog/3478898'
    expect(page).to have_selector '.icon-cite[aria-hidden="true"]', visible: false
  end

  it 'renders an accessible icon for sending items to a printer' do
    visit 'catalog/3478898'
    expect(page).to have_selector '.icon-share[aria-hidden="true"]', visible: false
    expect(page).to have_selector '.icon-print[aria-hidden="true"]', visible: false
  end

  it 'links to the PUL branding for a standard Open Graph' do
    visit 'catalog/3478898'
    expect(page).to have_css 'meta[property="og:image"][content*="/assets/pul_orange-icon-only"]', visible: false
  end

  context 'when the Document links to a resource on books.google.com' do
    it 'uses the books.google.com API to retrieve the thumbnail URL' do
      visit 'catalog/9741216'
      expect(page).to have_css 'meta[property="og:image"][content^="https://books.google.com/books/content"]', visible: false
    end
  end

  context 'when the Document links to a IIIF Manifest' do
    it 'uses a IIIF image server to retrieve the thumbnail URL' do
      visit 'catalog/4705307'
      expect(page).to have_css 'meta[property="og:image"][content$="-intermediate_file.jp2/full/!200,150/0/default.jpg"]', visible: false
    end
  end
end
