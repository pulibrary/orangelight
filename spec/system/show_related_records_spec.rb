# frozen_string_literal: true

require 'rails_helper'

describe 'Show related records', type: :system do
  before do
    stub_holding_locations
  end

  context 'with many related records' do
    before do
      visit '/catalog/99124945733506421'
    end
    it 'shows 3 related records by default' do
      expect(page).to have_selector('ul#linked-records-related_record_s li', count: 3)
    end

    it 'shows all related records when the button is pressed and sets focus', js: true do
      click_button 'Show 10 more related records'
      expect(page).to have_selector('ul#linked-records-related_record_s li', count: 13)
      sleep 2
      expect(page.evaluate_script("document.activeElement.id")).to eq('linked-records-related_record_s')
    end

    it 'can toggle back to 3 related records', js: true do
      click_button 'Show 10 more related records'
      sleep 1
      click_button 'Show fewer related records'
      expect(page).to have_selector('ul#linked-records-related_record_s li', count: 3)
    end
  end
  context 'with a title with vernacular display' do
    before do
      visit '/catalog/9947053043506421'
    end

    it 'has the related record title in latin script' do
      within('dd.blacklight-related_record_s') do
        expect(page).to have_content('[Risālat al-Zawrāʼ].')
        title_element = page.find('#linked-records-related_record_s-title')
        expect(title_element[:dir]).to eq('ltr') # the Latin transliteration is left-to-right
      end
    end
    it 'has the related record title in vernacular (Arabic) script' do
      within('dd.blacklight-related_record_s') do
        expect(page).to have_content('[رسالة الزوراء]')
        title_element = page.find('#linked-records-related_record_s-vern-title')
        expect(title_element[:dir]).to eq('rtl') # the Arabic text is right-to-left
      end
    end
  end
end
