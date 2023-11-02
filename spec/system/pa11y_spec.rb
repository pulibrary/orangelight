# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'pa11y' do
  it 'passes pa11y' do
    # Capybara.app_host = "http://localhost:3000"
    # stub_alma_holding_locations
    visit '/catalog/99122643653506421'
    results = `yarn pa11y https://catalog-staging.princeton.edu/catalog/99122643653506421`
    # byebug
    expect(results).to include('No issues found!')
  end
end
