# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "feedback emails", type: :request do
  context 'main feedback form' do
    it 'adds a flash message on success' do
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
  end
  context 'ask a question feedback form' do
    it 'adds a flash message on success' do
      post '/contact/question', params: {
        controller: "ContactController", 
        action: "question", 
        ask_a_question_form: {
          name: "TestUser", email: "test@test-domain.org", message: "Why?"
        }
      }
      expect(response).to be_successful
      expect(flash.notice).to eq('Your question has been submitted')
    end
  end


end
