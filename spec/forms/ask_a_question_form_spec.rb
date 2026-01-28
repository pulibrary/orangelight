# frozen_string_literal: true
require "rails_helper"

RSpec.describe AskAQuestionForm, libanswers: true do
  let(:valid_attributes) do
    {
      "name" => "Test",
      "email" => "test@test.org",
      "message" => "Why is the thumbnail wrong?",
      "context" => "http://example.com/catalog/1",
      "title" => "Example Record"
    }
  end

  describe "initialization" do
    it "takes a name, email, message, context, and title" do
      form = described_class.new(valid_attributes)

      expect(form.name).to eq "Test"
      expect(form.email).to eq "test@test.org"
      expect(form.message).to eq "Why is the thumbnail wrong?"
      expect(form.context).to eq "http://example.com/catalog/1"
      expect(form.title).to eq "Example Record"

      expect(form).to be_valid
    end
  end

  describe "submit" do
    it "sends an email and resets its attributes, setting itself as submitted" do
      stub_libanswers_api
      form = described_class.new(valid_attributes)

      form.submit
      expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: "quid=5678&"\
      "pquestion=%5BCatalog%5D+Example+Record&"\
      "pdetails=Why+is+the+thumbnail+wrong%3F%0A%0ASent+from+http%3A%2F%2Fexample.com%2Fcatalog%2F1+via+LibAnswers+API&"\
      "pname=Test&"\
      "pemail=test%40test.org",
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      form = described_class.new(valid_attributes.merge("name" => ""))
      expect(form).not_to be_valid
    end
    it "is invalid without an email" do
      form = described_class.new(valid_attributes.merge("email" => ""))
      expect(form).not_to be_valid
    end
    it "is invalid without an email-looking email" do
      form = described_class.new(valid_attributes.merge("email" => "test"))
      expect(form).not_to be_valid
    end
    it "is invalid without a message" do
      form = described_class.new(valid_attributes.merge("message" => ""))
      expect(form).not_to be_valid
    end
    it "is valid when the honeypot is filled in, so that the robots are fooled" do
      form = described_class.new(valid_attributes.merge("feedback_desc" => "12345"))
      expect(form).to be_valid
    end
  end
end
