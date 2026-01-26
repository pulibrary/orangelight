# frozen_string_literal: true
def stub_delivery_locations
  stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_paths.first, 'bibdata', 'delivery_locations.json')),
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
               body: file_fixture("../#{fixture_name}"),
               headers: { 'content-type': 'application/json' })
end
# rubocop:enable Metrics/ParameterLists

def stub_illiad_patron(disavowed: false, uid: "jstudent")
  patron_url = "https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/#{uid}"

  found_response = '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}'
  disavowed_response = '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"DIS","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}'

  stub_request(:get, patron_url)
    .to_return(status: 200, body: disavowed ? disavowed_response : found_response, headers: {})
end

def stub_illiad_request(uid: "jstudent")
  transaction_url = "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction"

  transaction_created = '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                        '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                        '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}'
  stub_request(:post, transaction_url)
    .with(body: hash_including("Username" => uid))
    .to_return(status: 200, body: transaction_created, headers: {})
end

def stub_illiad_note
  transaction_note_url = "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes"
  note_created = '{"Message":"An error occurred adding note to transaction 1093946"}'

  stub_request(:post, transaction_note_url)
    .to_return(status: 200, body: note_created, headers: {})
end

def stub_scsb_availability(bib_id:, institution_id:, barcode:, item_availability_status: "Available", error_message: nil)
  scsb_availability_params = { bibliographicId: bib_id, institutionId: institution_id }
  scsb_response = [{ itemBarcode: barcode, itemAvailabilityStatus: item_availability_status, errorMessage: error_message }]
  stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
    .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
    .to_return(status: 200, body: scsb_response.to_json)
end

def stub_libanswers_api
  stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
    .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
    .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
  stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/ticket/create')
end

def stub_failed_libanswers_api
  stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/ticket/create')
    .to_return(status: 500, body: '', headers: {})
  stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
    .to_return(status: 200, body: '{"access_token":"abcdef1234567890abcdef1234567890abcdef12","expires_in":604800}', headers: { 'Content-Type' => 'application/json' })
end
