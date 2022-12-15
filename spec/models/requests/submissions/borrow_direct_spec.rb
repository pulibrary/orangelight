# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
describe Requests::Submissions::BorrowDirect do
  let(:user_info) do
    {
      "netid" => "jstudent",
      "barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
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
        "item_id" => "3059236",
        "delivery_mode_3059236" => "print",
        "barcode" => "32101044283008",
        "enum" => "2000 (13th ed.)",
        "copy_number" => "1",
        "status" => "Not Charged",
        "type" => "bd",
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
      requestable:,
      bib:
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

  let(:borrow_direct) { described_class.new(submission) }

  it 'Borrow direct successful' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_return('abc123')
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.handled_by).to eq("borrow_direct")
    expect(borrow_direct.errors.count).to eq(0)
  end

  it 'Borrow direct unsuccessful error message says repeat request' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_raise(BorrowDirect::Error, "PRIRI003: Internal error; This is a duplicate of a recent request. This request will not be submitted.")
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.handled_by).to eq("borrow_direct")
    expect(borrow_direct.errors.count).to eq(1)
    expect(borrow_direct.errors.first[:error]).to eq("Ignoring duplicate Borrow Direct request: PRIRI003: Internal error; This is a duplicate of a recent request. This request will not be submitted.")
  end

  it 'Borrow direct unsuccessful error message says not repeat request' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_raise(BorrowDirect::Error, "PRIRI003: Internal error; Internal error")
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757"))
      .to_return(status: 200, body: responses[:transaction_created], headers: {})
    stub_request(:post, transaction_note_url)
      .to_return(status: 200, body: responses[:note_created], headers: {})
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.errors.count).to eq(0)
    expect(borrow_direct.handled_by).to eq("interlibrary_loan")
  end

  it 'Borrow unknown exception sends on to' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_raise(BorrowDirect::Error, "Other error")
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757"))
      .to_return(status: 200, body: responses[:transaction_created], headers: {})
    stub_request(:post, transaction_note_url)
      .to_return(status: 200, body: responses[:note_created], headers: {})
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.errors.count).to eq(0)
    expect(borrow_direct.handled_by).to eq("interlibrary_loan")
  end

  it 'Borrow direct unsuccessful, but no exception thrown sent on to illiad' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_return(nil)
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757", "CallNumber" => "HA202 .U581", "ItemInfo3" => "2000 (13th ed.)"))
      .to_return(status: 200, body: responses[:transaction_created], headers: {})
    stub_request(:post, transaction_note_url)
      .to_return(status: 200, body: responses[:note_created], headers: {})
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.handled_by).to eq("interlibrary_loan")
    expect(borrow_direct.errors.count).to eq(0)
  end

  it 'Borrow direct unsuccessful, but no exception thrown sent on to illiad and illiad errors' do
    borrow_direct_stub = ::BorrowDirect::RequestItem.new("22101007797777")
    expect(::BorrowDirect::RequestItem).to receive(:new).with("22101007797777").and_return(borrow_direct_stub)
    expect(borrow_direct_stub).to receive(:make_request).with("Firestone Library", isbn: '9780544343757').and_return(nil)
    stub_request(:get, patron_url)
      .to_return(status: 200, body: responses[:found], headers: {})
    stub_request(:post, transaction_url)
      .with(body: hash_including("Username" => "jstudent", "LoanTitle" => "County and city data book.", "ISSN" => "9780544343757", "CallNumber" => "HA202 .U581", "ItemInfo3" => "2000 (13th ed.)"))
      .to_return(status: 400, body: '{"Message":"An Error"}', headers: {})
    expect { borrow_direct.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
    expect(borrow_direct.handled_by).to eq("interlibrary_loan")
    expect(borrow_direct.errors.count).to eq(1)
    expect(borrow_direct.errors.first[:error]).to eq("Invalid Interlibrary Loan Request")
  end
  # rubocop:enable RSpec/MultipleExpectations
end
