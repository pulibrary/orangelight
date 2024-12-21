# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AskAQuestionForm, libanswers: true do
  context 'when a robot fills in the hidden honeypot field' do
    before do
      visit '/ask_a_question?ask_a_question_form%5Bid%5D=99101035463506421&ask_a_question_form%5Btitle%5D=Age+of+empires+%3A+art+of+the+Qin+and+Han+dynasties+%2F+Zhixin+Jason+Sun+%3B+with+contributions+by+I-tien+Hsing%2C+Cary+Y.+Liu%2C+Pengliang+Lu%2C+Lillian+Lan-ying+Tseng%2C+Yang+Hong%2C+Robin+D.+S.+Yates%2C+Zhonglin+Yukina+Zhang.'
      fill_in 'ask_a_question_form_name', with: 'I am robot'
      fill_in 'ask_a_question_form_email', with: 'robot@example.com'
      fill_in 'ask_a_question_form_message', with: 'beep beep boop boop'
      find('#ask_a_question_form_feedback_desc', visible: :hidden).set 'Filling in the honeypot field'
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
      expect(page).to have_text 'Your question has been submitted'
    end
  end
  describe 'pressing the send button' do
    before do
      stub_libanswers_api
      stub_holding_locations
      visit '/catalog/99101035463506421'
      scroll_to(:bottom) # needed when js: true
      click_link 'Ask a Question'
      fill_in 'ask_a_question_form_name', with: 'Agatha'
      fill_in 'ask_a_question_form_email', with: 'agatha@poi.uk'
      fill_in 'ask_a_question_form_message', with: 'Murder on the Orient Express'
    end
    it 'closes the modal', js: true do
      expect(page).to have_text('Ask a Question')
      expect(page).to have_text('Message')
      click_button 'Send'
      expect(current_path).to eq '/catalog/99101035463506421'
      expect(page).not_to have_text('Message')
    end
  end
end
