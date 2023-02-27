# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(ReportHarmfulLanguageForm) do
  context 'when a robot fills in the hidden honeypot field' do
    before do
      visit '/report_harmful_language?report_harmful_language_form[id]=99105509673506421&report_harmful_language_form[title]=Princeton+international.'
      fill_in 'report_harmful_language_form_message', with: 'Unhelpful message from a robot'
      find('#report_harmful_language_form_feedback_desc', visible: :hidden).set 'Filling in the honeypot field'
    end
    it 'does not generate an email' do
      expect { click_button 'Send' }.not_to change {
        ActionMailer::Base.deliveries.count
      }
    end
    it 'does report success' do
      click_button 'Send'
      expect(page).to have_text 'Thank you for reporting problematic language in the Princeton University Library catalog'
    end
  end
end
