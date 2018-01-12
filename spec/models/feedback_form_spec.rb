# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackForm do
  subject { described_class.new(params) }

  let(:params) do
    { name: 'Bob Smith',
      email: 'bsmith@university.edu',
      message: 'Awesome Site!!!!' }
  end

  describe 'A vaild Feedback Email' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'Can deliver a message' do
      expect(subject).to respond_to(:deliver)
    end

    context 'It has invalid data' do
      let(:params) do
        { name: 'Bar',
          email: 'foo',
          message: nil }
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#headers' do
    it 'returns mail headers' do
      expect(subject.headers).to be_truthy
    end

    it "Contains the submitter's email address" do
      expect(subject.headers[:from]).to eq('"Bob Smith" <bsmith@university.edu>')
    end
  end

  describe 'error_message' do
    it 'returns the configured error string' do
      expect(subject.error_message).to eq(I18n.t('blacklight.feedback.error'))
    end
  end
end
