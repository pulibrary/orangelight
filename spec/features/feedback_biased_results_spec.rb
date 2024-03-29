# frozen_string_literal: true

require 'rails_helper'

describe 'submitting biased results', js: true do
  before do
    allow(Flipflop).to receive(:search_result_form?).and_return(true)
  end

  it 'shows the search query with facets and submits the form' do
    stub_holding_locations
    visit '/catalog'
    fill_in('q', with: 'roman')
    click_on('search')
    click_on('Manuscript')
    click_link('please let us know')

    expect(page).to have_link('search results', href: "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/?f%5Bformat%5D%5B%5D=Manuscript&q=roman&search_field=all_fields")
    # accessible close icon
    # expect(page).to have_selector '.icon-moveback[aria-hidden="true"]'

    # form fields
    fill_in('Name (optional)', with: 'John Smith')
    fill_in('Email (optional)', with: 'jsmith@localhost.localdomain')
    fill_in('Message', with: 'Lorem ipsum dolor sit amet, consectetur...')

    click_on('Send')

    expect(page).to have_content('Your report has been submitted')
    expect(page).to have_content('Thank you for helping us identify an instance of bias in our Catalog Search Results.')
    expect(ActionMailer::Base.deliveries.length).to eq 1
  end
end
