# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search history' do
  context 'when using Voyager' do
    describe 'login link' do
      it 'brings user to account page on login' do
        valid_patron_response = fixture('/bibdata_patron_response.json')
        voyager_account_response = fixture('/generic_voyager_account_response.xml')
        valid_voyager_patron = JSON.parse('{"patron_id": "77777"}').with_indifferent_access
        valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
        ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
        current_illiad_user_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/jstudent"
        stub_request(:get, /#{Regexp.quote(ENV['bibdata_base'])}\/patron\/.*/)
          .to_return(status: 200, body: valid_patron_response, headers: {})
        stub_request(:get, valid_patron_record_uri)
          .to_return(status: 200, body: voyager_account_response, headers: {})
        stub_request(:get, current_illiad_user_uri)
          .to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
        visit '/search_history'
        click_button "Your Account"
        click_link "Login"
        click_link "Princeton faculty, staff, and students log in with NetID"
        expect(current_path).to eq account_path
      end
    end

    describe 'action buttons' do
      context 'and no searches have been performed' do
        it 'does not have a login button' do
          visit '/search_history'
          within('#content') do
            expect(page).not_to have_link("Login")
          end
        end
      end

      context 'and a search has been performed' do
        it 'has a clear search history button and no login button' do
          stub_holding_locations
          visit '/'
          find_button('search').click
          visit '/search_history'
          within('#content') do
            expect(page).to have_link("Clear search history")
            expect(page).not_to have_link("Login")
          end
        end
      end
    end
  end

  context 'when using Alma' do
    context 'and not logged in' do
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
      end

      context 'and no searches have been performed' do
        it 'has a login button' do
          visit '/search_history'
          within('#content') do
            expect(page).to have_link("Login", class: "btn-primary")
          end
        end

        it 'brings user back to search history page on login' do
          visit '/search_history'
          click_link "Login"
          click_link "Princeton faculty, staff, and students log in with NetID"
          expect(current_path).to eq blacklight.search_history_path
        end
      end

      context 'and searches have been performed' do
        it 'has a login button' do
          stub_holding_locations
          visit '/'
          find_button('search').click
          visit '/search_history'
          within('#content') do
            expect(page).to have_link("Login", class: "btn-primary")
          end
        end
      end
    end

    context 'and logged in' do
      let(:user) { FactoryBot.create(:user) }

      it 'does not have a login button' do
        login_as user
        visit '/search_history'
        within('#content') do
          expect(page).not_to have_link("Login", class: "btn-primary")
        end
      end
    end
  end
end
