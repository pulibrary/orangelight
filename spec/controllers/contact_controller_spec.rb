# frozen_string_literal: true
require "rails_helper"

RSpec.describe ContactController, type: :controller do
  before do
    stub_libanswers_api
  end
  describe "#question" do
    let(:ask_a_question_form) { instance_double(AskAQuestionForm) }
    before do
      allow(AskAQuestionForm).to receive(:new).and_return(ask_a_question_form)
    end
    it "successfully posts a question and receives a flash message" do
      allow(ask_a_question_form).to receive(:valid?).and_return(true)
      allow(ask_a_question_form).to receive(:submit).and_return(true)
      post :question, params: {
        ask_a_question_form: {
          name: "test",
          email: "test@princeton.edu",
          message: "Test message"
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:success]).to eq('Your question has been submitted')
    end
    it "handles an unsuccessful submission and receives a flash error message" do
      allow(ask_a_question_form).to receive(:valid?).and_return(false)
      allow(ask_a_question_form).to receive(:submit).and_return(false)

      post :question, params: {
        ask_a_question_form: {
          name: "test",
          email: "test@princeton.edu",
          message: ""
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:error]).to eq('There was a problem submitting your question')
    end
  end
  describe "#missing_item" do
    let(:missing_item_form) { instance_double(MissingItemForm) }
    before do
      allow(MissingItemForm).to receive(:new).and_return(missing_item_form)
    end
    it "successfully posts a missing item report and receives a flash message" do
      allow(missing_item_form).to receive(:valid?).and_return(true)
      allow(missing_item_form).to receive(:submit).and_return(true)
      post :missing_item, params: {
        missing_item_form: {
          name: "test",
          email: "test@princeton.edu",
          message: "Test message"
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:success]).to eq('Your missing item report has been submitted')
    end
    it "handles an unsuccessful submission and receives a flash error message" do
      allow(missing_item_form).to receive(:valid?).and_return(false)
      allow(missing_item_form).to receive(:submit).and_return(false)

      post :missing_item, params: {
        missing_item_form: {
          name: "test",
          email: "test@princeton.edu",
          message: ""
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:error]).to eq('There was a problem submitting your missing item report')
    end
  end
  describe "#suggestion" do
    let(:suggest_correction_form) { instance_double(SuggestCorrectionForm) }
    before do
      allow(SuggestCorrectionForm).to receive(:new).and_return(suggest_correction_form)
    end
    it "successfully posts a suggestion and receives a flash message" do
      allow(suggest_correction_form).to receive(:valid?).and_return(true)
      allow(suggest_correction_form).to receive(:submit).and_return(true)
      post :suggestion, params: {
        suggest_correction_form: {
          name: "test",
          email: "test@princeton.edu",
          message: "Test message"
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:success]).to eq('Your suggestion has been submitted')
    end
    it "handles an unsuccessful submission and receives a flash error message" do
      allow(suggest_correction_form).to receive(:valid?).and_return(false)
      allow(suggest_correction_form).to receive(:submit).and_return(false)

      post :suggestion, params: {
        suggest_correction_form: {
          name: "test",
          email: "test@princeton.edu",
          message: ""
        }
      }, format: :js

      expect(response).to be_successful
      expect(flash.now[:error]).to eq('There was a problem submitting your suggestion')
    end
  end
end
