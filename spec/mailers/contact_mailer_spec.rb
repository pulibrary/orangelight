# frozen_string_literal: true
require 'rails_helper'

describe ContactMailer, type: :mailer do
  context 'with a question' do
    let(:valid_attributes) do
      {
        "name" => "Test",
        "email" => "test@test.org",
        "message" => "Why is the thumbnail wrong?",
        "context" => "http://example.com/catalog/1",
        "title" => "Example Record"
      }
    end
    let(:form) do
      AskAQuestionForm.new(valid_attributes)
    end
    let(:mail) do
      described_class.with(form:).question.deliver_now
    end

    it "renders the headers" do
      mail
      expect(mail.subject).to eq("[Catalog] Example Record")
      expect(mail.to).to eq(["test-question@princeton.edu"])
      expect(mail.from).to eq(["test@test.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content('Name: Test')
      expect(mail.body.encoded).to have_content('Email: test@test.org')
      expect(mail.body.encoded).to have_content('Subject: [Catalog] Example Record')
      expect(mail.body.encoded).to have_content('Comments: Why is the thumbnail wrong?')
      expect(mail.body.encoded).to have_content('Context: http://example.com/catalog/1')
    end
  end

  context "with a harmful content form" do
    let(:form) do
      ReportHarmfulLanguageForm.new(valid_attributes)
    end
    let(:mail) do
      described_class.with(form:).harmful_language.deliver_now
    end

    context "with all fields filled in" do
      let(:valid_attributes) do
        {
          "name" => "Test",
          "email" => "test@test.org",
          "message" => "I am concerned about this subject heading",
          "context" => "http://example.com/catalog/1",
          "title" => "Example Record"
        }
      end

      it "renders the headers" do
        expect(mail.subject).to eq("[Possible Harmful Language] Example Record")
        expect(mail.to).to eq(["test-harmful-content@princeton.edu"])
        expect(mail.from).to eq(["test@test.org"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to have_content('Name: Test')
        expect(mail.body.encoded).to have_content('Email: test@test.org')
        expect(mail.body.encoded).to have_content('Subject: [Possible Harmful Language] Example Record')
        expect(mail.body.encoded).to have_content('Comments: I am concerned about this subject heading')
        expect(mail.body.encoded).to have_content('Context: http://example.com/catalog/1')
      end
    end

    context 'with minimal valid attributes' do
      let(:valid_attributes) do
        {
          "name" => "",
          "email" => "",
          "message" => "I am concerned about this subject heading",
          "context" => "http://example.com/catalog/1",
          "title" => "Example Record"
        }
      end

      it "renders the headers" do
        expect(mail.subject).to eq("[Possible Harmful Language] Example Record")
        expect(mail.to).to eq(["test-harmful-content@princeton.edu"])
        expect(mail.from).to eq(["test-harmful-content@princeton.edu"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to have_content('Name: ')
        expect(mail.body.encoded).to have_content('Email: ')
        expect(mail.body.encoded).to have_content('Subject: [Possible Harmful Language] Example Record')
        expect(mail.body.encoded).to have_content('Comments: I am concerned about this subject heading')
        expect(mail.body.encoded).to have_content('Context: http://example.com/catalog/1')
      end
    end
  end
end
