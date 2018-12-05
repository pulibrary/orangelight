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

  context 'when an entry has a bib. ID for a resource published in Figgy' do
    before do
      visit 'catalog/3753928'
    end

    it 'updates the thumbnail and constructs an instance of the Universal Viewer' do
      expect(page).to have_selector 'iframe'
      expect(page).to have_selector '.document-thumbnail img[src$="default.jpg"]'
    end
  end

  context 'when an entry has a bib. ID and ARK for a resource published in Figgy' do
    before do
      visit 'catalog/3395923'
    end

    it 'updates the thumbnail and constructs an instance of the Universal Viewer' do
      expect(page).to have_selector 'iframe'
      expect(page).to have_selector '.document-thumbnail img[src$="default.jpg"]'
    end

    it 'updates the link to the ARK with a fragment identifier for the UV' do
      expect(page).to have_selector '.electronic-access a[href$="3395923#view"]', text: 'Digital content'
    end
  end

  context 'when an entry has a title statement' do
    before do
      visit 'catalog/8181849'
    end

    it 'renders the title and title statement separately' do
      expect(page).to have_selector '.header-row h1', text: 'Jōmyō genron / 浄名玄論'
      expect(page).to have_selector '.header-row h2', text: 'Kyōto Kokuritsu Hakubutsukan hen ; kaisetsu Ishihara Harumichi (Hokkaidō Daigaku Meiyo Kyōju), Akao Eikei (Kyōto Kokuritsu Hakubutsukan Gakugeibu Jōseki Kenkyūin).'
    end
  end

  context 'when the title_display field is nearly identical to the title_citation_display field' do
    before do
      visit 'catalog/4609321'
    end

    it 'only renders the title_display' do
      expect(page).to have_selector '.header-row h1', text: 'Bible, Latin'
      expect(page).not_to have_selector '.header-row h2'
    end
  end
end
