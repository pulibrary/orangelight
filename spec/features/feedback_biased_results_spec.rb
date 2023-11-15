# frozen_string_literal: true

require 'rails_helper'

describe 'submitting biased results', js: true do
  before do
    visit '/feedback/biased_results?report_biased_results_form[q]=cats'
    fill_in(id: 'feedback_form_name', with: 'John Smith')
    fill_in(id: 'feedback_form_email', with: 'jsmith@localhost.localdomain')
    fill_in(id: 'feedback_form_message', with: 'Lorem ipsum dolor sit amet, consectetur...')
    click_on('Send')
  end

  it 'renders an accessible icon for returning' do
    expect(page).to have_selector '.icon-moveback[aria-hidden="true"]'
  end
end
