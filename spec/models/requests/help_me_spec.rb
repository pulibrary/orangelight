# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
describe Requests::Submissions::HelpMe do
  let(:user_info) do
    {
      "netid" => "jstudent",
      "barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch",
      "campus_authorized" => true
    }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: {}, patron: user_info) }
  let(:requestable) do
    [
      {
        "selected" => "true",
        "mfhd" => "22113812720006421",
        "call_number" => "HA202 .U581",
        "location_code" => "recap$pa",
        "item_id" => "23113812570006421",
        "delivery_mode_3059236" => "print",
        "barcode" => "32101044283008",
        "enum_display" => "2000 (13th ed.)",
        "copy_number" => "1",
        "status" => "Not Charged",
        "type" => "help_me",
        "edd_start_page" => "",
        "edd_end_page" => "",
        "edd_volume_number" => "",
        "edd_issue" => "",
        "edd_author" => "",
        "edd_art_title" => "",
        "edd_note" => "",
        "pick_up" => "Firestone Library"
      },
      {
        "selected" => "false"
      }
    ]
  end
  let(:bib) do
    {
      "id" => "994916543506421",
      "title" => "County and city data book.",
      "author" => "United States",
      "date" => "1949",
      "isbn" => '9780544343757'
    }
  end
  let(:params) do
    {
      request: user_info,
      requestable: requestable,
      bib: bib
    }
  end

  let(:submission) do
    Requests::Submission.new(params, patron)
  end

  let(:patron_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/Users/jstudent" }
  let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
  let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      disavowed: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"DIS","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                          '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                          '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
      note_created: '{"Message":"An error occurred adding note to transaction 1093946"}'
    }
  end

  let(:good_request_response) { 'A BD Request Number' }
  let(:bad_request_response) { 'An error happened' }

  let(:help_me) { described_class.new(submission) }

  it 'Help Me successful' do
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757"))
      .to_return(status: 200, body: responses[:transaction_created], headers: {})
    stub_request(:post, transaction_note_url)
      .with(body: hash_including("Note" => "Help Me Get It Request: User has access to physical item pickup"))
      .to_return(status: 200, body: responses[:note_created], headers: {})
    expect { help_me.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(help_me.errors.count).to eq(0)
  end

  context "User does not have access to pickup" do
    let(:user_info) do
      {
        "netid" => "jstudent",
        "barcode" => nil,
        "email" => "foo@princeton.edu",
        "source" => "pulsearch"
      }.with_indifferent_access
    end

    it 'Help Me successful with different note' do
      stub_request(:get, patron_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      stub_request(:post, transaction_url)
        .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757"))
        .to_return(status: 200, body: responses[:transaction_created], headers: {})
      stub_request(:post, transaction_note_url)
        .with(body: hash_including("Note" => "Help Me Get It Request: User does not have access to physical item pickup"))
        .to_return(status: 200, body: responses[:note_created], headers: {})
      expect { help_me.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
      expect(help_me.errors.count).to eq(0)
    end
  end

  it 'when illiad errors it returns an error' do
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757"))
      .to_return(status: 400, body: '{"Message":"An Error"}', headers: {})
    expect { help_me.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(help_me.errors.count).to eq(1)
    expect(help_me.errors.first[:error]).to eq("Invalid Help Me Request")
  end
  # rubocop:enable RSpec/MultipleExpectations
end
