require 'rails_helper'

describe "My Account", :type => :feature do
  
  context "User has not signed in" do

    it "Account information displays as not available" do
      visit('/account')
      expect(page).to have_content 'Log in with Princeton Net ID'
    end
    
  end

  context "Princeton Community User has signed in" do

    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    # FIXME - Had trouble reading the fixture IO Closed Stream error so faking it right now
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before(:each) do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}").
         with(:headers => {'User-Agent'=>'Faraday v0.9.2'}).
         to_return(:status => 200, :body => valid_patron_response, :headers => {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 200, body: voyager_account_response, headers: {})

      sign_in user
      visit('/account')
    end

    it "Displays Basic Patron Information" do
      
      expect(page).to have_content 'Your Account'
      expect(page).to have_css '.netid'
      expect(page).to have_css '.barcode'
    end

    it "Displays item charged out with due dates" do
      expect(page).to have_content 'Charged Items'
      expect(page).to have_content 'Due Date'
    end

    it "Displays item eligibility for renewal" do
      expect(page).to have_content 'Renew?'
    end

    it "Displays outstanding fines" do
      expect(page).to have_content 'No Outstanding Fines or Fees'
    end

    it "Display active requests" do
      expect(page).to have_content 'Pickup Location'
    end

    it "Displays items for pickup" do
      expect(page).to have_content 'No items available for pickup'
    end
  end
  
end