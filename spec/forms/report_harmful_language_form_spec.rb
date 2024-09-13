# frozen_string_literal: true
require "rails_helper"

RSpec.describe ReportHarmfulLanguageForm, libanswers: true do
  let(:valid_attributes) do
    {
      "name" => "Test",
      "email" => "test@test.org",
      "message" => "I am concerned about this subject heading",
      "context" => "http://example.com/catalog/1",
      "title" => "Example Record"
    }
  end

  let(:minimal_valid_attributes) do
    {
      "name" => "",
      "email" => "",
      "message" => "I am concerned about this subject heading",
      "context" => "http://example.com/catalog/1",
      "title" => "Example Record"
    }
  end

  describe "initialization" do
    it "takes a name, email, message, context, and title" do
      form = described_class.new(valid_attributes)

      expect(form.name).to eq "Test"
      expect(form.email).to eq "test@test.org"
      expect(form.message).to eq "I am concerned about this subject heading"
      expect(form.context).to eq "http://example.com/catalog/1"
      expect(form.title).to eq "Example Record"

      expect(form).to be_valid
    end
  end

  describe "submit" do
    it "sends a libanswers API call and resets its attributes, setting itself as submitted" do
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
      ).with(body: 'quid=9012&'\
      'pquestion=[Possible Harmful Language] Example Record&'\
      "pdetails=I am concerned about this subject heading\n\nSent from http://example.com/catalog/1 via LibAnswers API&"\
      'pname=Test&'\
      'pemail=test@test.org',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
    end

    it "sends an email with minimal valid form attributes" do
      stub_libanswers_api
      form = described_class.new(minimal_valid_attributes)

      form.submit
      expect(form).to be_submitted

      expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=9012&'\
      'pquestion=[Possible Harmful Language] Example Record&'\
      "pdetails=I am concerned about this subject heading\n\nSent from http://example.com/catalog/1 via LibAnswers API&"\
      'pname=&'\
      'pemail=',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
    end
  end

  describe "validations" do
    it "is valid without a name" do
      form = described_class.new(valid_attributes.merge("name" => ""))
      expect(form).to be_valid
    end
    it "is valid without an email" do
      form = described_class.new(valid_attributes.merge("email" => ""))
      expect(form).to be_valid
    end
    it "is invalid without a message" do
      form = described_class.new(valid_attributes.merge("message" => ""))
      expect(form).not_to be_valid
    end
  end
end
