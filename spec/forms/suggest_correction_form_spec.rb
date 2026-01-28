# frozen_string_literal: true
require "rails_helper"

RSpec.describe SuggestCorrectionForm, libanswers: true do
  let(:valid_attributes) do
    {
      "name" => "Test",
      "email" => "test@test.org",
      "message" => "You should fix the thumbnail",
      "context" => "http://example.com/catalog/1",
      "title" => "Example Record"
    }
  end

  describe "initialization" do
    it "takes a name, email, message, context, and title" do
      form = described_class.new(valid_attributes)

      expect(form.name).to eq "Test"
      expect(form.email).to eq "test@test.org"
      expect(form.message).to eq "You should fix the thumbnail"
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
      expect(form.name).to eq ""
      expect(form.email).to eq ""
      expect(form.message).to eq ""
      expect(form.context).to eq "http://example.com/catalog/1"
      expect(form.title).to eq "Example Record"
      expect(form).to be_submitted

      expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: "quid=3456&"\
      "pquestion=%5BCatalog%5D+Example+Record&"\
      "pdetails=You+should+fix+the+thumbnail%0A%0ASent+from+http%3A%2F%2Fexample.com%2Fcatalog%2F1+via+LibAnswers+API&"\
      "pname=Test&"\
      "pemail=test%40test.org",
             headers: {
              Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12',
              'Content-Type': 'application/x-www-form-urlencoded',
              Accept: '*/*',
              'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent': 'Ruby'
            })
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
  end
end
