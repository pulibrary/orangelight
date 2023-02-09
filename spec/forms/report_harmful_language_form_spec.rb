# frozen_string_literal: true
require "rails_helper"

RSpec.describe ReportHarmfulLanguageForm do
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

  describe "#email_subject" do
    it "uses the name of the object" do
      form = described_class.new(valid_attributes)

      expect(form.email_subject).to eq "[Possible Harmful Language] Example Record"
    end
  end

  describe "submit" do
    it "sends an email and resets its attributes, setting itself as submitted" do
      form = described_class.new(valid_attributes)

      form.submit
      expect(ActionMailer::Base.deliveries.length).to eq 1
      expect(form.name).to eq ""
      expect(form.email).to eq ""
      expect(form.message).to eq ""
      expect(form.context).to eq "http://example.com/catalog/1"
      expect(form.title).to eq "Example Record"
      expect(form).to be_submitted

      mail = ActionMailer::Base.deliveries.first
      expect(mail.subject).to eq "[Possible Harmful Language] Example Record"
      expect(mail.from).to eq ["test@test.org"]
      expect(mail.body).to include "Name: Test"
      expect(mail.body).to include "Email: test@test.org"
      expect(mail.body).to include "[Possible Harmful Language] Example Record"
      expect(mail.body).to include "Comments: I am concerned about this subject heading"
      expect(mail.body).to include "Context: http://example.com/catalog/1"
    end

    it "sends an email with minimal valid form attributes" do
      form = described_class.new(minimal_valid_attributes)

      form.submit
      expect(ActionMailer::Base.deliveries.length).to eq 1
      expect(form).to be_submitted

      mail = ActionMailer::Base.deliveries.first
      expect(mail.subject).to eq "[Possible Harmful Language] Example Record"
      expect(mail.from).to eq ["test-harmful-content@princeton.edu"]
      expect(mail.body).to include "Name: "
      expect(mail.body).to include "Email: "
      expect(mail.body).to include "[Possible Harmful Language] Example Record"
      expect(mail.body).to include "Comments: I am concerned about this subject heading"
      expect(mail.body).to include "Context: http://example.com/catalog/1"
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
