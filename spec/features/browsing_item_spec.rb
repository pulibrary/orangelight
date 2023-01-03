# frozen_string_literal: true

require 'rails_helper'

describe 'browsing a catalog item', js: true do
  before do
    stub_holding_locations
  end

  it 'renders an accessible icon for citing the item' do
    visit 'catalog/9934788983506421'
    expect(page).to have_selector('.icon-cite[aria-hidden="true"]')
  end

  it 'renders an accessible icon for sending items to a printer' do
    visit 'catalog/9934788983506421'
    expect(page).to have_selector('.icon-share[aria-hidden="true"]')
    expect(page).to have_selector('.icon-print[aria-hidden="true"]', visible: :hidden)
  end

  context 'when an entry has a bib. ID for a resource published in Figgy', skip: true do
    before do
      visit 'catalog/9970446223506421'
    end

    it 'updates the thumbnail and constructs an instance of the Universal Viewer' do
      using_wait_time 40 do
        expect(page).to have_selector('iframe')
        expect(page).to have_selector('.document-thumbnail img[src$="default.jpg"]')
      end
    end
  end

  context 'when an entry has a bib. ID and ARK for a resource published in Figgy', skip: true do
    before do
      visit 'catalog/9970446223506421'
    end

    it 'updates the thumbnail and constructs an instance of the Universal Viewer' do
      using_wait_time 10 do
        expect(page).to have_selector('iframe')
        expect(page).to have_selector('.document-thumbnail img[src$="default.jpg"]')
      end
    end

    it 'updates the link to the ARK with a fragment identifier for the UV' do
      using_wait_time 10 do
        expect(page).to have_selector('.availability--online a[href$="7044622#view"]', text: 'Table of contents')
      end
    end
  end
end
