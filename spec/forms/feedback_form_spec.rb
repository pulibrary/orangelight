# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackForm do
  subject(:form) { described_class.new(params) }

  let(:params) do
    { name: 'Bob Smith',
      email: 'bsmith@university.edu',
      message: 'Awesome Site!!!!' }
  end

  describe 'A vaild Feedback Email' do
    it 'is valid' do
      expect(form).to be_valid
    end

    it 'Can deliver a message' do
      expect(form).to respond_to(:deliver)
    end

    context 'It has invalid data' do
      let(:params) do
        { name: 'Bar',
          email: 'foo',
          message: nil }
      end

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end
  end

  describe '#headers' do
    it 'returns mail headers' do
      expect(form.headers).to be_truthy
    end

    it 'pulls TO header from configuration' do
      expect(form.headers[:to]).to eq 'test@princeton.edu'
    end

    it 'pulls CC header from configuration' do
      expect(form.headers[:cc]).to eq 'test2w@princeton.edu, test3@princeton.edu'
    end

    it "Contains the submitter's email address" do
      expect(form.headers[:from]).to eq('"Bob Smith" <bsmith@university.edu>')
    end
  end

  describe 'error_message' do
    it 'returns the configured error string' do
      expect(form.error_message).to eq(I18n.t('blacklight.feedback.error'))
    end
  end

  describe "deliver" do
    it "sends an email" do
      form = described_class.new({
                                   email: 'test@test.org',
                                   name: 'A Nice Tester',
                                   message: 'Good job on the catalog!'
                                 })

      expect { form.deliver }.to change { ActionMailer::Base.deliveries.length }.by 1
      mail = ActionMailer::Base.deliveries.first
      expect(mail.subject).to eq "Princeton University Library Catalog Feedback Form"
      expect(mail.from).to eq ["test@test.org"]
      expect(mail.body).to include "Good job on the catalog!"
    end
  end

  describe 'remote_ip' do
    it 'gets the IP from the request, if available' do
      form.request = instance_double(ActionDispatch::Request)
      allow(form.request).to receive(:remote_ip).and_return('10.11.12.13')
      expect(form.remote_ip).to eq('10.11.12.13')
    end
  end

  describe 'user_agent' do
    it 'gets the User agent from the request, if available' do
      form.request = instance_double(ActionDispatch::Request)
      allow(form.request).to receive(:user_agent).and_return('Firefox')
      expect(form.user_agent).to eq('Firefox')
    end
  end
end
