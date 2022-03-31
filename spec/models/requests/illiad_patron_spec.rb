require 'rails_helper'
require 'net/ldap'

describe Requests::IlliadPatron, type: :controller do
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu", "ldap" => ldap_data }.with_indifferent_access
  end
  let(:ldap_data) { { uid: 'foo', department: 'Library - Information Technology', address: 'Firestone Library$Library Information Technology', telephone: '123-456-7890', surname: 'Doe', givenname: 'Joe', email: 'joe@abc.com', pustatus: 'fac', status: 'faculty' }.with_indifferent_access }
  let(:user_info) do
    user = instance_double(User, guest?: false, uid: 'foo')
    Requests::Patron.new(user: user, session: {}, patron: valid_patron)
  end

  let(:illiad_patron) { described_class.new(user_info) }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"foo","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_found: '{"Message":"User abc123 was not found."}',
      client_created: '{"UserName":"foo","ExternalUserId":"foo","LastName":"User","FirstName":"Test","SSN":"99999999999","Status":"staff","EMailAddress":"foo@test.com","Phone":"609-258-1378","Department":"Library - Information Technology","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-06-24T10:56:24.55","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"Firestone Library","Address2":"Library Information Technology","City":"Princeton","State":"NJ","Zip":"08544","Site":"Firestone","ExpirationDate":"2021-06-24T10:56:24.55","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      user_already_exits: '{"Message":"The request is invalid.","ModelState":{"UserName":["Username foo already exists."]}}',
      invalid: '{"Message":"The request is invalid.","ModelState":{"model.UserName":["The UserName field is required."]}}'
    }
  end

  describe '#illiad_patron' do
    let(:stub_url_base) do
      "#{illiad_patron.illiad_api_base}/ILLiadWebPlatform/Users"
    end

    let(:stub_url) do
      "#{stub_url_base}/#{user_info.netid}"
    end

    it "captures when user is not present" do
      stub_request(:get, stub_url)
        .to_return(status: 404, body: responses[:not_found], headers: {})
      expect(illiad_patron.illiad_patron).to be_blank
    end

    it "captures connection exceptions" do
      stub_request(:get, stub_url).and_raise(Faraday::ConnectionFailed, "failed")
      expect(illiad_patron.illiad_patron).to be_blank
    end

    it "returns data when user is present" do
      stub_request(:get, stub_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      patron = illiad_patron.illiad_patron
      expect(patron).not_to be_blank
      expect(patron[:UserName]).to eq('abc234')
      expect(patron[:ExternalUserId]).to eq('foo')
      expect(patron[:Cleared]).to eq('Yes')
    end

    it "can create a patron" do
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "F - Faculty", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 200, body: responses[:client_created], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).not_to be_blank
      expect(patron["UserName"]).to eq('foo')
      expect(patron["ExternalUserId"]).to eq('foo')
      expect(patron["Cleared"]).to eq('Yes')
    end

    context "student" do
      let(:ldap_data) { { uid: 'foo', department: 'College', address: 'Firestone Library$Library Information Technology', telephone: '123-456-7890', surname: 'Doe', givenname: 'Joe', email: 'joe@abc.com', pustatus: 'undergraduate', status: 'student' }.with_indifferent_access }

      it "can create a student" do
        stub_request(:post, stub_url_base)
          .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                     "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "U - Undergraduate", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "College", "Web" => true,
                                     "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
          .to_return(status: 200, body: responses[:client_created], headers: {})
        patron = illiad_patron.create_illiad_patron
        expect(patron).not_to be_blank
        expect(patron["UserName"]).to eq('foo')
        expect(patron["ExternalUserId"]).to eq('foo')
        expect(patron["Cleared"]).to eq('Yes')
      end
    end

    context "staff" do
      let(:ldap_data) { { uid: 'foo', department: 'Information Technology', address: 'Firestone Library$Library Information Technology', telephone: '123-456-7890', surname: 'Doe', givenname: 'Joe', email: 'joe@abc.com', pustatus: 'stf', status: 'staff' }.with_indifferent_access }

      it "ignores client already exists when creating a patron" do
        stub_request(:post, stub_url_base)
          .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                     "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "GS - University Staff", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "Information Technology", "Web" => true,
                                     "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
          .to_return(status: 400, body: responses[:user_already_exits], headers: {})
        stub_request(:get, stub_url)
          .to_return(status: 200, body: responses[:found], headers: {})
        patron = illiad_patron.create_illiad_patron
        expect(patron).not_to be_blank
        expect(patron[:UserName]).to eq('abc234')
        expect(patron[:ExternalUserId]).to eq('foo')
        expect(patron[:Cleared]).to eq('Yes')
      end
    end

    it "responds with a blank patron if there is an error creating it" do
      stub_request(:post, stub_url_base)
        .with(body: hash_including("Username" => 'foo', "ExternalUserId" => "foo", "FirstName" => "Foo", "LastName" => "Request", "EmailAddress" => "foo@princeton.edu", "DeliveryMethod" => "Hold for Pickup", "LoanDeliveryMethod" => "Hold for Pickup",
                                   "NotificationMethod" => "Electronic", "Phone" => "123-456-7890", "Status" => "F - Faculty", "AuthType" => "Default", "NVTGC" => "ILL", "Department" => "Library - Information Technology", "Web" => true,
                                   "Address" => "Firestone Library", "Address2" => "Library Information Technology", "City" => "Princeton", "State" => "NJ", "Zip" => "08544", "SSN" => "22101007797777", "Cleared" => "Yes", "Site" => "Firestone"))
        .to_return(status: 400, body: responses[:invalid], headers: {})
      patron = illiad_patron.create_illiad_patron
      expect(patron).to be_blank
    end
  end

  context "ldap data is blank" do
    let(:ldap_data) { {} }
    it "returns empty attributes when illiad user is not present" do
      expect(illiad_patron.attributes).to eq({})
    end
  end

  context "ldap data is blank except for status" do
    let(:ldap_data) { { status: 'faculty' } }
    it "returns empty attributes when illiad user is not present" do
      expect(illiad_patron.attributes).to eq({})
    end
  end
end
