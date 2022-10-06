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

      it 'has accessible labels for Alma login inputs' do
        visit '/users/sign_in'
        click_link("Log in with Alma Account (affiliates)")
        # Username
        expect(page).to have_selector('#username')
        username_label_element = page.find('label', text: 'Alma user name')
        expect(username_label_element['for']).to eq("username")
        expect(username_label_element.text).to eq('Alma user name')
        # Password
        expect(page).to have_selector('#password')
        password_label_element = page.find('label', text: 'Password')
        expect(password_label_element['for']).to eq('password')
        expect(password_label_element.text).to eq('Password')
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
  describe 'Account login from requests page' do
    before do
      stub_request(:post, 'https://scsb.recaplib.org:9093/sharedCollection/bibAvailabilityStatus')
        .to_return(status: 200, body: [{ itemBarcode: 'CU71562478', itemAvailabilityStatus: "Available" }].to_json)
      # I'm not sure why the patron number being requested is `1234`, but this is what's needed to get the correct response
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/1234?ldap=true")
        .to_return(status: 200, body: patron_response, headers: {})
      stub_holding_locations
      stub_delivery_locations
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2143785/raw")
        .to_return(status: 200, body: fixture('/scsb/SCSB-2143785.json'), headers: {})
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/scsbcul.json")
        .to_return(status: 200, body: fixture('/bibdata/scsbcul_holding_locations.json'))
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/SCSB-2143785/holdings/2110046/availability.json")
        .to_return(status: 200)
    end

    context 'with a CAS account' do
      let(:user) { FactoryBot.create(:user) }
      let(:patron_response) { File.open(fixture_path + '/bibdata_patron_response_barcode.json') }

      it 'logs the user in', js: true do
        visit "/catalog/SCSB-2143785"
        click_link('Request')
        expect(page).to have_link('Log in with netID')
        click_link('Log in with netID')
        expect(page.body).to include('Successfully authenticated from Princeton Central Authentication Service.')
        expect(page.body).to include('Library Material Request')
        expect(page.current_url).to include('/requests/SCSB-2143785?aeon=false')
        expect(page).to have_selector('#request_3270290')
      end

      context 'without logging in but trying to hack the url' do
        it 'does not display options to select' do
          visit '/requests/SCSB-2143785?aeon=true'
          expect(page.body).to include('Library Material Request')
          expect(page).not_to have_selector('#request_3270290')
        end
      end
    end
    context 'with an Alma account' do
      let(:user) { FactoryBot.create(:valid_alma_patron) }
      let(:patron_response) { File.open(fixture_path + '/alma_login_response.json') }
      let(:expected_login_url) { 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/Alma%20Patron?op=auth&password=foobarfoo' }

      before do
        stub_request(:post, expected_login_url)
          .to_return(status: 204)
      end
      it 'logs the user in', js: true do
        visit "/catalog/SCSB-2143785"
        click_link('Request')
        expect(page.body).to include('Log in with Alma Account (affiliates)')
        click_link('Log in with Alma Account (affiliates)')
        fill_in(id: 'username', with: user.username)
        fill_in(id: 'password', with: user.password)
        click_button('Log in')
        expect(WebMock).to have_requested(:post, expected_login_url)
        expect(page.body).to include('Successfully authenticated with alma account. Please log out to protect your privacy when using a shared computer')
        expect(page.body).to include('Library Material Request')
      end

      context 'an aeon item' do
        describe 'requesting a coin' do
          before do
            stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/coin-1167/raw")
              .to_return(status: 200, body: fixture('/numismatics/coin-1167.json'), headers: {})
            stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/rare$num.json")
              .to_return(status: 200, body: fixture('/bibdata/numismatics_holding_locations.json'))
          end

          it 'does not require authentication', js: true do
            visit "/catalog/coin-1167"
            expect(page).to have_link('Reading Room Request', href: '/requests/coin-1167?aeon=true&mfhd=numismatics')
            click_link('Reading Room Request')
            expect(page.current_url).to include(Requests::Config[:aeon_base])
          end
        end
        describe 'requesting a thesis' do
          before do
            stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/dsp01tq57ns24j/raw")
              .to_return(status: 200, body: fixture('/theses_and_dissertations/dsp01tq57ns24j.json'), headers: {})
            stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/mudd$stacks.json")
              .to_return(status: 200, body: fixture('/bibdata/mudd_stacks_holding_locations.json'))
          end
          it 'does not require authentication', js: true do
            visit "/catalog/dsp01tq57ns24j"
            expect(page).to have_link('Reading Room Request', href: '/requests/dsp01tq57ns24j?aeon=true&mfhd=thesis')
            click_link('Reading Room Request')
            expect(page.current_url).to include(Requests::Config[:aeon_base])
          end
        end
        describe 'requesting a special collections holding with a single item' do
          let(:availability) do
            '[{"barcode":"32101070796881","id":"23745123320006421","holding_id":"22745123330006421","copy_number":"1","status":"Available","status_label":"Item in place","status_source":"base_status","process_type":null,"on_reserve":"N","item_type":"Closed","pickup_location_id":"rare","pickup_location_code":"rare","location":"rare$map","label":"Special Collections - Rare Books Historic Map Collection","description":"","enum_display":"","chron_display":"","in_temp_library":false}]'
          end
          before do
            stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/99496133506421/raw")
              .to_return(status: 200, body: fixture('/alma/99496133506421.json'), headers: {})
            stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/rare$map.json")
              .to_return(status: 200, body: fixture('/bibdata/rare_map_holding_locations.json'))
            stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/99496133506421/holdings/22745123330006421/availability.json")
              .to_return(status: 200, body: availability)
          end
          it 'does not require authentication', js: true do
            visit "/catalog/99496133506421"
            expect(page).to have_link('Reading Room Request', href: '/requests/99496133506421?aeon=true&mfhd=22745123330006421')
            click_link('Reading Room Request', href: '/requests/99496133506421?aeon=true&mfhd=22745123330006421')
            expect(page.current_url).to include(Requests::Config[:aeon_base])
          end
        end
      end
    end
  end
end
