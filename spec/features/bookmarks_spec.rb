# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bookmarks' do
  context 'when using Voyager' do
    describe 'login link' do
      it 'brings user to account page on login' do
        ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
        current_illiad_user_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/jstudent"
        stub_request(:get, current_illiad_user_uri).to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
        valid_patron_response = fixture('/bibdata_patron_response.json')
        voyager_account_response = fixture('/generic_voyager_account_response.xml')
        valid_voyager_patron = JSON.parse('{"patron_id": "77777"}').with_indifferent_access
        valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
        stub_request(:get, /#{Regexp.quote(Requests.config['bibdata_base'])}\/patron\/.*/)
          .to_return(status: 200, body: valid_patron_response, headers: {})
        stub_request(:get, valid_patron_record_uri)
          .to_return(status: 200, body: voyager_account_response, headers: {})
        visit '/bookmarks'
        click_button "Your Account"
        click_link "Login"
        click_link "Princeton faculty, staff, and students log in with NetID"
        expect(current_path).to eq account_path
      end
    end

    describe 'action buttons' do
      it 'has a clear bookmarks button' do
        visit '/bookmarks'
        expect(page).to have_link("Clear bookmarks")
      end

      it 'does not have login links' do
        visit '/bookmarks'
        within('#content') do
          expect(page).not_to have_link("log in")
        end
      end
    end
  end

  context 'when using Alma' do
    before do
      allow(Rails.configuration).to receive(:use_alma).and_return(true)
    end

    describe 'action buttons' do
      it 'has a clear bookmarks button' do
        visit '/bookmarks'
        expect(page).to have_link("Clear bookmarks")
      end
    end

    context 'when not logged in' do
      it 'has login links' do
        visit '/bookmarks'
        within('#content') do
          expect(page).to have_link("log in")
        end
      end

      it 'logging in brings user back to bookmarks page' do
        visit '/bookmarks'
        click_link "log in"
        click_link "Princeton faculty, staff, and students log in with NetID"
        expect(current_path).to eq bookmarks_path
      end
    end

    context 'when logged in' do
      let(:user) { FactoryBot.create(:user) }

      it 'does not have login links' do
        login_as user
        visit '/bookmarks'
        within('#content') do
          expect(page).not_to have_link("log in")
        end
      end
    end
  end
end
