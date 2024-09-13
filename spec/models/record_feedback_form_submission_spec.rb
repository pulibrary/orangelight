# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RecordFeedbackFormSubmission, libanswers: true do
  it 'sends the feedback via Libanswers API' do
    stub_libanswers_api

    described_class.new(
        message: 'This terminology needs some updates please!',
        patron_name: 'Miles Morales',
        patron_email: 'spiderman@example.com',
        title: '[Possible Harmful Language] Some old book', # the title of the record the patron was looking at
        context: 'https://catalog.princeton.edu/catalog/12345', # the URL of the record the patron was looking at
        quid: 9012 # the libanswers queue
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=9012&'\
      'pquestion=[Possible Harmful Language] Some old book&'\
      "pdetails=This terminology needs some updates please!\n\nSent from https://catalog.princeton.edu/catalog/12345 via LibAnswers API&"\
      'pname=Miles Morales&'\
      'pemail=spiderman@example.com',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
  it 'has a configurable queue id' do
    stub_libanswers_api

    described_class.new(
        quid: 12345,
        message: '', patron_name: '', patron_email: '', title: '', context: ''
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=12345&'\
      'pquestion=&'\
      "pdetails=\n\nSent via LibAnswers API&"\
      'pname=&'\
      'pemail=',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
end
