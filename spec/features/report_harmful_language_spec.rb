# frozen_string_literal: true

require 'rails_helper'

describe 'reporting harmful language', js: true do
  it 'gives an error when the email is invalid' do
    visit 'report_harmful_language?report_harmful_language_form[id]=1234&report_harmful_language_form[title]=Book'
    fill_in(id: 'report_harmful_language_form_message', with: 'Lorem ipsum dolor sit amet, consectetur...')
    fill_in(id: 'report_harmful_language_form_name', with: 'John Smith')
    fill_in(id: 'report_harmful_language_form_email', with: 'john@smith')

    click_on('Send')

    expect(page).to have_content 'Email is not a valid email address'
  end

  context 'when the form is in a modal' do
    it 'gives an error within the modal the email is invalid' do
      stub_holding_locations
      visit 'catalog/99116000543506421'
      click_link 'Report Harmful Language'
      fill_in(id: 'report_harmful_language_form_message', with: 'Lorem ipsum dolor sit amet, consectetur...')
      fill_in(id: 'report_harmful_language_form_name', with: 'John Smith')
      fill_in(id: 'report_harmful_language_form_email', with: 'john@smith')

      click_on('Send')

      expect(page).to have_content 'Email is not a valid email address'
      expect(current_path).to eq '/catalog/99116000543506421' # we should not go to another path, the validation should appear in the modal
    end
  end
end
