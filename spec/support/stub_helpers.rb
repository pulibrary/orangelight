# frozen_string_literal: true
def stub_delivery_locations
  stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/delivery_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'delivery_locations.json')),
               headers: {})
end

def stub_alma_hold_success(id, mfhd, item_id, patron_id)
  stub_alma_hold(id, mfhd, item_id, patron_id)
end

def stub_alma_hold_failure(id, mfhd, item_id, patron_id)
  stub_alma_hold(id, mfhd, item_id, patron_id, status: 400, fixture_name: "alma_hold_error_no_library_response.json")
end

# rubocop:disable Metrics/ParameterLists
def stub_alma_hold(id, mfhd, item_id, patron_id, status: 200, fixture_name: "alma_hold_response.json")
  stub_url = "#{Alma.configuration.region}/almaws/v1/bibs/#{id}/holdings/#{mfhd}/items/#{item_id}/requests?user_id=#{patron_id}"
  stub_request(:post, stub_url)
    .to_return(status:,
               body: fixture(fixture_name),
               headers: { 'content-type': 'application/json' })
  stub_url
end
# rubocop:enable Metrics/ParameterLists

def stub_clancy_post(barcode:, status: 'Item Requested', deny: 'N')
  clancy_url = "#{Requests::Config[:clancy_base]}/circrequests/v1"
  stub_request(:post, clancy_url).to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"request_count\":\"1\",\"results\":[{\"item\":\"#{barcode}\",\"deny\":\"#{deny}\",\"istatus\":\"#{status}\"}]}", headers: {})
  clancy_url
end

def stub_clancy_status(barcode:, status: "Item not Found")
  stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/#{barcode}")
    .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"#{barcode}\",\"status\":\"#{status}\"}", headers: {})
end

def stub_illiad_patron(disavowed: false)
  patron_url = 'https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/jstudent'
  found_response = '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}'
  disavowed_response = '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"DIS","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}'

  stub_request(:get, patron_url)
    .to_return(status: 200, body: disavowed ? disavowed_response : found_response, headers: {})
end

def stub_scsb_availability(bib_id:, institution_id:, barcode:, item_availability_status: "Available", error_message: nil)
  scsb_availability_params = { bibliographicId: bib_id, institutionId: institution_id }
  scsb_response = [{ itemBarcode: barcode, itemAvailabilityStatus: item_availability_status, errorMessage: error_message }]
  stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
    .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
    .to_return(status: 200, body: scsb_response.to_json)
end
