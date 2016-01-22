require 'rails_helper'

RSpec.describe ApplicationHelper do

  let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
  
  describe "#patron_account?" do

    let(:valid_user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:invalid_user) { FactoryGirl.create(:invalid_princeton_patron) }
    let(:unauthorized_user) { FactoryGirl.create(:unauthorized_princeton_patron) }
          
    it "Returns Princeton Patron Account Data using a NetID" do
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 200, body: valid_patron_response, headers: {})

      patron = current_patron? valid_user.uid
      expect(patron).to be_truthy
    end

    it "Returns false when an ID doesn't exist" do
      invalid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{invalid_user.uid}"
      stub_request(:get, invalid_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 404, body: '<html><title>Not Here</title><body></body></html>', headers: {})
      
      patron = current_patron? invalid_user.uid
      expect(patron).to be_falsey
    end

    it "Returns false when the application isn't authorized to access patron data" do
      unauthorized_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{unauthorized_user.uid}"
      stub_request(:get, unauthorized_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 403, body: '<html><title>Not Authorized</title><body></body></html>', headers: {})
      
      patron = current_patron? unauthorized_user.uid
      expect(patron).to be_falsey
    end

  end

  describe "#voyager_account?" do

    let(:valid_voyager_response) { File.open(fixture_path + '/pul_voyager_account_response.xml').read }
    let(:valid_voyager_patron) { JSON.parse("#{valid_patron_response.read}").with_indifferent_access }
    let(:invalid_voyager_patron) { JSON.parse('{ "patron_id": "foo" }').with_indifferent_access }
    let(:unauthorized_voyager_patron) { JSON.parse('{ "patron_id": "bar" }').with_indifferent_access }

    it "Returns Voyager account data using a valid patron record" do
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 200, body: valid_voyager_response, headers: {})
      
      account = voyager_myaccount? valid_voyager_patron
      expect(account).to be_truthy
      expect(account.doc.is_a? Nokogiri::XML::Document).to be_truthy
    end

    it "Returns false when the patron record doesn't exist" do      
      invalid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{invalid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, invalid_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 404, body: "Account Not Found", headers: {})

      account = voyager_myaccount? invalid_voyager_patron
      expect(account).to be_falsey
    end

    it "Returns false when the application isn't authorized to access Voyager account data" do
      unauthorized_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{unauthorized_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, unauthorized_patron_record_uri).
        with(headers: { "User-Agent"=>"Faraday v0.9.2" }).
        to_return(status: 403, body: "Application Not Authorized", headers: {})

      account = voyager_myaccount? unauthorized_voyager_patron
      expect(account).to be_falsey
    end

  end

end