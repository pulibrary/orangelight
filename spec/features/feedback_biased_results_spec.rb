# frozen_string_literal: true

require 'rails_helper'

describe 'submitting biased results', js: true do
  before do
    visit '/feedback/biased_results?report_biased_results_form[q]=cats'
  end

  it 'submits the message' do
    fill_in('Name (optional)', with: 'John Smith')
    fill_in('Email (optional)', with: 'jsmith@localhost.localdomain')
    fill_in('Message', with: 'Lorem ipsum dolor sit amet, consectetur...')
    click_on('Send')
    expect(page).to have_content('Your report has been submitted')
    expect(page).to have_content('Thank you for helping us identify an instance of bias in our Catalog Search Results.')
  end

  # it 'renders an accessible icon for returning' do
  #   expect(page).to have_selector '.icon-moveback[aria-hidden="true"]'
  # end
  it 'shows the search query' do
    expect(page).to have_content('It looks like you were searching for the term(s) cats')
    expect(page).to have_link('search results', href: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/catalog?q=cats")
  end
end
