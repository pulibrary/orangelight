# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AskAQuestionFormSubmission, libanswers: true do
  it 'sends the feedback via Libanswers API' do
    stub_libanswers_api

    described_class.new(
        message: 'How can I find books about electricity?',
        patron_name: 'Miles Morales',
        patron_email: 'spiderman@example.com',
        title: 'Venom : the secrets of nature\'s deadliest weapon', # the title of the record the patron was looking at
        context: 'https://catalog.princeton.edu/catalog/12345' # the URL of the record the patron was looking at
      ).send_to_libanswers

    expect(WebMock).to have_requested(
        :post,
        'https://faq.library.princeton.edu/api/1.1/ticket/create'
      ).with(body: 'quid=5678&'\
      'pquestion=[Catalog] Venom : the secrets of nature\'s deadliest weapon&'\
      "pdetails=How can I find books about electricity?\n\nSent from https://catalog.princeton.edu/catalog/12345 via LibAnswers API&"\
      'pname=Miles Morales&'\
      'pemail=spiderman@example.com',
             headers: { Authorization: 'Bearer abcdef1234567890abcdef1234567890abcdef12' })
  end
end
