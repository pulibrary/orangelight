# frozen_string_literal: true

require 'rails_helper'

describe 'reporting harmful language', js: true do
  before do
    visit 'report_harmful_language?report_harmful_language_form[id]=1234&report_harmful_language_form[title]=Book'
    fill_in(id: 'report_harmful_language_form_message', with: 'Lorem ipsum dolor sit amet, consectetur...')
    fill_in(id: 'report_harmful_language_form_name', with: 'John Smith')
    fill_in(id: 'report_harmful_language_form_email', with: 'john@smith')
    click_on('Send')
  end

  it 'gives an error when the email is invalid' do
    pending 'see https://github.com/pulibrary/orangelight/issues/4655'
    expect(page).to have_content 'Email is not a valid email address'
  end
end
