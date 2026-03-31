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
      ).with(body: "quid=9012&"\
      "pquestion=%5BPossible+Harmful+Language%5D+Some+old+book&"\
      "pdetails=This+terminology+needs+some+updates+please%21%0A%0ASent+from+https%3A%2F%2Fcatalog.princeton.edu%2Fcatalog%2F12345+via+LibAnswers+API&"\
      "pname=Miles+Morales&"\
      "pemail=spiderman%40example.com",
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
  it 'has a configurable queue id' do
    stub_libanswers_api

    described_class.new(
        quid: 12_345,
        message: '', patron_name: '', patron_email: '', title: '', context: ''
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: "quid=12345&"\
      "pquestion=&"\
      "pdetails=%0A%0ASent+via+LibAnswers+API&"\
      "pname=&"\
      "pemail=",
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
  it 'truncates the pquestion field to 150 characters' do
    stub_libanswers_api

    long_title = 'ABCDEF ' * 50

    described_class.new(
        message: 'Feedback message',
        patron_name: 'Test User',
        patron_email: 'test@example.com',
        title: long_title,
        context: 'https://catalog.princeton.edu/catalog/12345',
        quid: 12_345
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: "quid=12345&"\
      "pquestion=#{CGI.escape("#{'ABCDEF ' * 20}ABCDEF...")}&"\
      "pdetails=Feedback+message%0A%0ASent+from+https%3A%2F%2Fcatalog.princeton.edu%2Fcatalog%2F12345+via+LibAnswers+API&"\
      "pname=Test+User&"\
      "pemail=test%40example.com",
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
end
