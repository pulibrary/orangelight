# frozen_string_literal: true
require 'rails_helper'

describe 'Account login' do
  let(:user) { FactoryBot.create(:user) }
  let(:login_and_redirect_to_alma_url) { "/users/sign_in?origin=%2Fredirect-to-alma" }

  describe 'Your Account menu', js: true do
    it "lists correct options when not logged in" do
      visit "/"
      click_button("Your Account")
      within('li.show') do
        link = find_link("Library Account")
        expect(link[:href]).to include login_and_redirect_to_alma_url
        expect(link[:target]).to eq("_blank")
        expect(link[:id]).to eq('unauthenticated-library-account-link')
        expect(has_css?('i.fa-external-link', count: 1)).to eq true
        expect(page).not_to have_link("ILL & Digitization Requests", href: digitization_requests_path)
        expect(page).to have_link("Bookmarks", href: bookmarks_path)
        expect(page).to have_link("Search History", href: blacklight.search_history_path)
        expect(page).not_to have_link("Log Out")
      end
    end

    it "lists correct options when logged in" do
      login_as user
      visit "/"
      click_button(user.username)
      within('li.show') do
        link = find_link("Library Account")
        expect(link[:href]).to include login_and_redirect_to_alma_url
        expect(link[:target]).to eq("_blank")
        expect(link[:id]).to be_empty
        expect(has_css?('i.fa-external-link', count: 1)).to eq true
        expect(page).to have_link("ILL & Digitization Requests", href: digitization_requests_path)
        expect(page).to have_link("Bookmarks", href: bookmarks_path)
        expect(page).to have_link("Search History", href: blacklight.search_history_path)
        expect(page).to have_link("Log Out")
      end
    end
  end

  describe "Library Account login", js: true do
    context "as an unauthenticated user" do
      it "redirects to the log in page and then to alma" do
        visit "/"
        click_button("Your Account")
        new_window = window_opened_by { click_link 'Library Account' }
        within_window new_window do
          expect(page).to have_link("Log in with netID")
          expect(page).to have_link("Log in with Alma Account (affiliates)")
          cas_login_link = find_link('Log in with netID')
          expect(cas_login_link[:href]).to include("/users/auth/cas")
          click_link('Log in with netID')
          expect(page.current_url).to include("https://princeton.alma.exlibrisgroup.com/discovery/")
        end
      end
    end
    context "as an authenticated user" do
      before do
        login_as user
      end

      it "redirects the user to alma" do
        visit "/"
        click_button(user.username)
        new_window = window_opened_by { click_link 'Library Account' }
        within_window new_window do
          expect(page.current_url).to include("https://princeton.alma.exlibrisgroup.com/discovery/")
        end
      end
    end
  end
  describe 'Alma account login from requests page' do
    let(:alma_user) { FactoryBot.create(:valid_alma_patron) }
    let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
    let(:valid_patron_record_uri) { "#{Requests.config['bibdata_base']}/patron/#{alma_user.uid}" }
    let(:expected_login_url) { 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/Alma%20Patron?op=auth&password=foobarfoo' }
    before do
      stub_holding_locations
      stub_delivery_locations
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2143785/raw")
        .to_return(status: 200, body: fixture('/scsb/SCSB-2143785.json'), headers: {})
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/scsbcul.json")
        .to_return(status: 200, body: fixture('/bibdata/scsbcul_holding_locations.json'))
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/SCSB-2143785/holdings/2110046/availability.json")
        .to_return(status: 400)
      stub_request(:post, expected_login_url)
        .to_return(status: 204)
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'logs the user in', js: true do
      visit "/catalog/SCSB-2143785"
      click_link('Request')
      expect(page.body).to include('Log in with Alma Account (affiliates)')
      click_link('Log in with Alma Account (affiliates)')
      fill_in(id: 'username', with: alma_user.username)
      fill_in(id: 'password', with: alma_user.password)
      click_button('Log in')
      expect(WebMock).to have_requested(:post, expected_login_url)
      expect(page.body).to include('Successfully authenticated with alma account. Please log out to protect your privacy when using a shared computer')
      expect(page.body).to include('Library Material Request')
    end
  end
end
