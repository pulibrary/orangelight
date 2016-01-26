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

    it "Displays an unchecked option to renew item request" do
      expect(page.has_no_checked_field?('renew_items[]')).to be_truthy
    end

    it "Displays charged items as renewable" do
      expect(page).to have_css('#item-renew .account--charged_items input')
      expect(page.first('.account--charged_items input').value).to eq('item-17365:barcode-32608')
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

  context "Princeton Community User has signed in with a block and active requests" do
    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/voyager_account_with_block.xml') }
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

    it "displays the patrons block" do
      expect(page).to have_content("Active Patron Blocks")
    end

    it "displays the reason for the patron's block" do
      expect(page).to have_content("You have overdue recalled items. Please return this material Immediately")
    end

    it "Displays an unchecked option to cancel the request" do
      expect(page.has_no_checked_field?('cancel_requests[]')).to be_truthy
    end

    it "Displays the item and hold recall ID" do
      expect(page).to have_css('#request-cancel .account--requests input')
      expect(page.find('.account--requests input').value).to eq('item-7114238:holdrecall-587476:type-R')
    end

    it "Displays the position of the request in the hold queue" do
      expect(page).to have_content("Position: 1")
    end

    it "Displays a formatted date when the request expires" do
      expect(page).to have_content('Expires: July 24 2016 at 12:00 AM')
    end

    it "Displays the selected Pickup Location" do
      expect(page).to have_content('.Firestone Library Circulation Desk')
    end
  end

  context "Princeton Community User has signed in with an overdue item and fines" do
    let(:user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/account_with_block_fines_recall.xml') }
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

    it "displays item as overdue" do
      expect(page).to have_content("Overdue")
    end

    it "displays properly formatted overdue dates" do
      expect(page).to have_content("January 25 2016 at 11:45 PM")
    end

    it "displays fines and fines" do
      expect(page).to have_css(".account--fines")
    end

    it "displays the type of fines" do
      expect(page).to have_content('Overdue')
      expect(page).to have_content('Lost Item Replacement')
    end

    it "displays the amount of fines" do
      expect(page).to have_content('15.00')
      expect(page).to have_content('599.00')
    end

    it "displays the balance of fines" do
      expect(page).to have_content('15.00')
      expect(page).to have_content('599.00')
      expect(page).to have_content('50.00')
    end

    it "displays the total amount due" do
      expect(page).to have_css('.account--fines_total')
      expect(page).to have_content('664.00')
    end

    it "Allows You to Renew Renewable Items" do
    end

  end
  
end