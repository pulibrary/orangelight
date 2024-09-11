# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FeedbackFormSubmission, libanswers: true do
  it 'sends the feedback via Libanswers API' do
    stub_libanswers_api

    described_class.new(
        message: 'I have some thoughts about the catalog',
        patron_name: 'Miles Morales',
        patron_email: 'spiderman@example.com',
        user_agent: 'Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
        current_url: 'https://catalog.princeton.edu/catalog/12345'
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=1234&'\
      'pquestion=Princeton University Library Catalog Feedback Form&'\
      "pdetails=I have some thoughts about the catalog\n\nSent from https://catalog.princeton.edu/catalog/12345 via LibAnswers API&"\
      'pname=Miles Morales&'\
      'pemail=spiderman@example.com&'\
      'ua=Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
end
