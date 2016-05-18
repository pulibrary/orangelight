require 'rails_helper'

describe 'Feedback Form', type: :feature do
  context 'User has not signed in' do
    before(:each) do
      visit('/catalog/4747577')
      click_link('Contact Us')
    end

    it 'Displays an empty form' do
      expect(page).to have_content 'Send Us Feedback'
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
    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
    it 'Populates Email Field' do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .with(headers: { 'User-Agent' => 'Faraday v0.9.2' })
        .to_return(status: 200, body: valid_patron_response, headers: {})
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.9.2' })
        .to_return(status: 200, body: voyager_account_response, headers: {})
      sign_in user
      visit('/catalog/4747577')
      click_link('Contact Us')
      expect(page).to have_field('feedback_form_email', with: "#{user.uid}@princeton.edu")
    end
  end
end
