# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

describe 'Feedback form error handling', type: :system, js: true do
  before do
    stub_failed_libanswers_api
  end

  it 'shows the ticket submission error message when ticket creation fails' do
    visit '/feedback'
    fill_in 'feedback_form_name', with: 'Aspen Chor'
    fill_in 'feedback_form_email', with: 'aspenchor@example.com'
    fill_in 'feedback_form_message', with: 'Test ticket_submission_error message'
    click_button 'Send'
    expect(page).to have_css('.alert-danger', text: I18n.t('blacklight.feedback.ticket_submission_error'))
  end
end
