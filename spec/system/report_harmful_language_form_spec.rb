# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReportHarmfulLanguageForm, libanswers: true do
  context 'when a robot fills in the hidden honeypot field' do
    before do
      visit '/report_harmful_language?report_harmful_language_form[id]=99105509673506421&report_harmful_language_form[title]=Princeton+international.'
      fill_in 'report_harmful_language_form_message', with: 'Unhelpful message from a robot'
      find('#report_harmful_language_form_feedback_desc', visible: :hidden).set 'Filling in the honeypot field'
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
      expect(page).to have_text 'Thank you for reporting problematic language in the Princeton University Library catalog'
    end
  end
end
