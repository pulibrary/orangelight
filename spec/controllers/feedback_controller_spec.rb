# frozen_string_literal: true
require "rails_helper"

RSpec.describe FeedbackController, type: :controller do
  describe "#ask_a_question" do
    it "routes to the Ask A Question form" do
      get :ask_a_question

      expect(response).to be_successful
    end
  end
end
