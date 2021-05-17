# frozen_string_literal: true

require 'rails_helper'

describe 'Feedback Form', type: :feature do
  before do
    stub_holding_locations
    ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
    current_illiad_user_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/jstudent"
    stub_request(:get, current_illiad_user_uri).to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
  end

  context 'User has not signed in' do
    before do
      visit('/catalog/4747577')
      click_link('Feedback')
    end

    it 'Displays an empty form' do
      expect(page).to have_content 'Feedback'
      expect(page).to have_field 'feedback_form_name'
      expect(page).to have_field 'feedback_form_email'
      expect(page).to have_field 'feedback_form_message'
    end

    it 'Fill ins and submits a valid form Form', js: true do
      fill_in 'feedback_form_name', with: 'Joe Smith'
      fill_in 'feedback_form_email', with: 'jsmith@university.edu'
      fill_in 'feedback_form_message', with: 'awesome site'
      click_button 'Send'
      expect(page).to have_content(I18n.t('blacklight.feedback.confirmation'))
    end

    describe 'It provides error messages', js: true do
      it 'When the name field is not filled in' do
        fill_in 'feedback_form_email', with: 'foo@university.edu'
        fill_in 'feedback_form_message', with: 'awesome site'
        click_button 'Send'
        expect(page).to have_content(I18n.t('blacklight.feedback.error'))
        expect(page).to have_selector('.has-error')
      end
    end
  end

  context 'Princeton Community User has signed in' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    it 'Populates Email Field' do
      stub_request(:get, "#{Requests.config['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})
      sign_in user
      visit('/catalog/4747577')
      click_link('Feedback')
      expect(page).to have_field('feedback_form_email', with: "#{user.uid}@princeton.edu")
    end
  end
end
