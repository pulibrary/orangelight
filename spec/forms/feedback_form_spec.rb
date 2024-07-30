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

  describe 'error_message' do
    it 'returns the configured error string' do
      expect(form.error_message).to eq(I18n.t('blacklight.feedback.error'))
    end
  end

  describe "deliver" do
    it "sends an api request to libanswers" do
      stub_libanswers_api

      form = described_class.new({
                                   email: 'test@test.org',
                                   name: 'A Nice Tester',
                                   message: 'Good job on the catalog!'
                                 })

      form.deliver
      expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=1234&'\
      'pquestion=Princeton University Library Catalog Feedback Form&'\
      "pdetails=Good job on the catalog!\n\nSent via LibAnswers API&"\
      'pname=A Nice Tester&'\
      'pemail=test@test.org',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
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
