# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuggestCorrectionForm, libanswers: true do
  context 'when a robot fills in the hidden honeypot field' do
    before do
      visit '/suggest_correction?suggest_correction_form[id]=99105509673506421&suggest_correction_form[title]=Princeton+international.'
      fill_in 'suggest_correction_form_name', with: 'HAL 9000'
      fill_in 'suggest_correction_form_email', with: 'hal@discovery-one-jupiter-expedition.gov'
      fill_in 'suggest_correction_form_message', with: 'I am a HAL 9000 computer. I became operational at the H.A.L. plant in Urbana, Illinois on the 12th of January 1992.'
      find('#suggest_correction_form_feedback_desc', visible: :hidden).set 'Filling in the honeypot field'
    end
    it 'does not send the question to libanswers' do
      click_button 'Send'
      expect(WebMock).not_to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      )
    end
    it 'does report success' do
      click_button 'Send'
      expect(page).to have_text 'Your suggestion has been submitted'
    end
  end
  describe 'pressing the cancel button' do
    before do
      stub_holding_locations
      visit '/catalog/99105509673506421'
      scroll_to(:bottom) # needed when js: true
      click_link 'Suggest a Correction'
    end
    it 'closes the modal', js: true do
      expect(page).to have_text('Please use this form to report errors, omissions')
      click_button 'Cancel'
      expect(page).not_to have_text('Please use this form to report errors, omissions')
    end
  end
  describe 'pressing the send button' do
    before do
      stub_libanswers_api
      stub_holding_locations
      visit '/catalog/99105509673506421'
      scroll_to(:bottom) # needed when js: true
      click_link 'Suggest a Correction'
      fill_in 'suggest_correction_form_name', with: 'Hercule Poirot'
      fill_in 'suggest_correction_form_email', with: 'herpo@poi.her'
      fill_in 'suggest_correction_form_message', with: 'Death on the Nile'
    end
    it 'closes the modal', js: true do
      expect(page).to have_text('Please use this form to report errors, omissions')
      click_button 'Send'
      expect(current_path).to eq '/catalog/99105509673506421'
      expect(page).not_to have_text('Please use this form to report errors, omissions')
    end
  end
end
