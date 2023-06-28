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
      expect(flash[:success]).to eq('Your question has been submitted')
    end
  end
  context 'report_harmful_language feedback form' do
    let(:params) do
      {
        controller: "ContactController",
        action: "report_harmful_language",
        report_harmful_language_form: {
          message: "Why?"
        }
      }
    end
    it 'adds a flash message on success' do
      post('/contact/report_harmful_language', params:)
      expect(response).to be_successful
      expect(flash[:success]).to eq('Your report has been submitted')
    end

    context 'with an invalid form' do
      it 'renders the report_harmful_language_form' do
        mock_form = instance_double("ReportHarmfulLanguageForm")
        allow(ReportHarmfulLanguageForm).to receive(:new).and_return(mock_form)
        allow(mock_form).to receive(:valid?).and_return(false)
        allow(mock_form).to receive(:model_name).and_return(ReportHarmfulLanguageForm.model_name)
        allow(mock_form).to receive(:to_key)
        allow(mock_form).to receive(:name)
        allow(mock_form).to receive(:email)
        allow(mock_form).to receive(:message)
        allow(mock_form).to receive(:context)
        allow(mock_form).to receive(:title)
        allow(mock_form).to receive(:feedback_desc)
        post('/contact/report_harmful_language', params:)

        expect(response).to render_template('catalog/_report_harmful_language_form')
      end
    end
  end
end
