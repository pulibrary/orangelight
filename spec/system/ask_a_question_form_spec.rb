# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(AskAQuestionForm) do
  context 'when a robot fills in the hidden honeypot field' do
    before do
      visit '/ask_a_question?ask_a_question_form%5Bid%5D=99101035463506421&ask_a_question_form%5Btitle%5D=Age+of+empires+%3A+art+of+the+Qin+and+Han+dynasties+%2F+Zhixin+Jason+Sun+%3B+with+contributions+by+I-tien+Hsing%2C+Cary+Y.+Liu%2C+Pengliang+Lu%2C+Lillian+Lan-ying+Tseng%2C+Yang+Hong%2C+Robin+D.+S.+Yates%2C+Zhonglin+Yukina+Zhang.'
      fill_in 'ask_a_question_form_name', with: 'I am robot'
      fill_in 'ask_a_question_form_email', with: 'robot@example.com'
      fill_in 'ask_a_question_form_message', with: 'beep beep boop boop'
      find('#ask_a_question_form_feedback_desc', visible: :hidden).set 'Filling in the honeypot field'
    end
    it 'does not generate an email' do
      expect { click_button 'Send' }.not_to change {
        ActionMailer::Base.deliveries.count
      }
    end
    it 'does report success' do
      click_button 'Send'
      expect(page).to have_text 'Your question has been submitted'
    end
  end
end
