# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "feedback forms", type: :request, libanswers: true do
  context 'main feedback form' do
    it 'adds a flash message on success' do
      stub_libanswers_api
      post '/feedback.js', params: {
        controller: "FeedbackController",
        action: "create",
        feedback_form: {
          name: "TestUser", email: "test@test-domain.org", message: "Why?"
        }
      }
      expect(response).to be_successful
      expect(flash.notice).to eq('Your comments have been submitted')
    end

    it 'renders the ticket submission error message when ticket creation fails' do
      stub_failed_libanswers_api

      post '/feedback.js', params: {
        controller: "FeedbackController",
        action: "create",
        feedback_form: {
          name: "TestUser", email: "test@test-domain.org", message: "Why?"
        }
      }
      expect(response).to be_successful
      expect(flash[:error]).to eq(I18n.t('blacklight.feedback.ticket_submission_error'))
    end
  end
  context 'ask a question feedback form' do
    it 'adds a flash message on success' do
      stub_libanswers_api
      post '/contact/question', params: {
        controller: "ContactController",
        action: "question",
        ask_a_question_form: {
          name: "TestUser", email: "test@test-domain.org", message: "Why?"
        }, format: :js
      }
      expect(response).to be_successful
      expect(flash.now[:success]).to eq('Your question has been submitted')
    end
  end
end
