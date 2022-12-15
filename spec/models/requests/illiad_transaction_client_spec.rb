# frozen_string_literal: true
require 'rails_helper'
require 'net/ldap'

describe Requests::IlliadTransactionClient, type: :controller do
  let(:valid_patron) { { "netid" => "abc234", ldap: { status: "faculty", pustatus: "fac" } }.with_indifferent_access }
  let(:user_info) do
    user = instance_double(User, guest?: false, uid: 'foo')
    Requests::Patron.new(user:, session: {}, patron: valid_patron)
  end
  let(:requestable) do
    [{ "selected" => "true", "bibid" => "10921934", "mfhd" => "22241110470006421", "call_number" => "HF1131 .B485",
       "location_code" => "f", "item_id" => "7892830", "barcode" => "32101102865654", "enum" => "2019",
       "copy_number" => "0", "status" => "Not Charged", "type" => "on_shelf", "pick_up" => "PA", "edd_author" => "That One",
       "edd_genre" => "journal", "edd_isbn" => "", "edd_date" => "", "edd_publisher" => "Santa Barbara, Calif: ABC-CLIO",
       "edd_call_number" => "HF1131 .B485", "edd_oclc_number" => "1033410889", "edd_title" => "Best business schools", "edd_note" => "Customer note" }]
    # {"selected"=>"true", "bibid"=>"3510207", "mfhd"=>"3832636", "call_number"=>"D25 .D385 1999",
    # "location_code"=>"f", "item_id"=>"3052428", "barcode"=>"32101044636858", "copy_number"=>"1",
    # "status"=>"Not Charged", "type"=>"on_shelf", "pick_up"=>"PA"}
  end

  let(:bib) do
    { "id" => "9935102073506421", "title" => "100 decisive battles : from ancient times to the present", "author" => "Davis, Paul K.",
      "isbn" => "9781576070758", "oclc_number" => "42579288", "date" => "1999" }
  end

  let(:params) do
    {
      request: user_info,
      requestable:,
      bib:
    }
  end

  let(:submission) do
    Requests::Submission.new(params, user_info)
  end

  let(:metadata_mapper) { Requests::IlliadMetadata::ArticleExpress.new(patron: submission.patron, bib: submission.bib, item: submission.items.first) }

  let(:illiad_transaction) { described_class.new(patron: submission.patron, metadata_mapper:) }

  let(:responses) do
    {
      found: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"Yes","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_cleared: '{"UserName":"abc234","ExternalUserId":"123abc","LastName":"Alpha","FirstName":"Capa","SSN":"9999999","Status":"GS - Library Staff","EMailAddress":"abc123@princeton.edu","Phone":"99912345678","Department":"Library","NVTGC":"ILL","NotificationMethod":"Electronic","DeliveryMethod":"Hold for Pickup","LoanDeliveryMethod":"Hold for Pickup","LastChangedDate":"2020-04-06T11:08:05","AuthorizedUsers":null,"Cleared":"New","Web":true,"Address":"123 Blah Lane","Address2":null,"City":"Blah Place","State":"PA","Zip":"99999","Site":"Firestone","ExpirationDate":"2021-04-06T11:08:05","Number":null,"UserRequestLimit":null,"Organization":null,"Fax":null,"ShippingAcctNo":null,"ArticleBillingCategory":null,"LoanBillingCategory":null,"Country":null,"SAddress":null,"SAddress2":null,"SCity":null,"SState":null,"SZip":null,"SCountry":null,"RSSID":null,"AuthType":"Default","UserInfo1":null,"UserInfo2":null,"UserInfo3":null,"UserInfo4":null,"UserInfo5":null,"MobilePhone":null}',
      not_found: '{"Message":"User abc123 was not found."}',
      note: '{ "Note" : "Digitization Request", "NoteType" : "Staff" }',
      note_created: '{"Message":"An error occurred adding note to transaction 1093946"}',
      transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"PhotoJournalIssue":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                           '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                           '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":null,"DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
      invalid_patron: '{"Message":"The request is invalid.","ModelState":{"model.UserName":["The UserName field is required."]}}'
    }
  end

  describe '#create_request' do
    let(:user_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/Users" }
    let(:patron_url) { "#{user_url}/#{user_info.netid}" }
    let(:transaction_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction" }
    let(:transaction_note_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction/1093806/notes" }

    it "returns data when user is present" do
      stub_request(:get, patron_url)
        .to_return(status: 200, body: responses[:found], headers: {})
      stub_request(:post, transaction_url)
        .with(body: hash_including("Username" => "abc234", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "That One", "PhotoItemAuthor" => "Davis, Paul K.", "PhotoJournalTitle" => "100 decisive battles : from ancient times to the present", "PhotoItemPublisher" => "Santa Barbara, Calif: ABC-CLIO", "ISSN" => "9781576070758", "CallNumber" => "HF1131 .B485", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9935102073506421", "PhotoJournalVolume" => "",
                                   "PhotoJournalIssue" => nil, "ItemInfo3" => nil, "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1033410889", "DocumentType" => "Book", "PhotoArticleTitle" => nil))
        .to_return(status: 200, body: responses[:transaction_created], headers: {})
      stub_request(:post, transaction_note_url)
        .with(body: hash_including("Note" => "Digitization Request: Customer note"))
        .to_return(status: 200, body: responses[:note_created], headers: {})
      transaction = illiad_transaction.create_request
      expect(transaction).not_to be_blank
      expect(transaction["Username"]).to eq('abc123')
      expect(transaction["TransactionNumber"]).to eq(1_093_806)
    end

    it "does not post a transaction when there is an error with the patron" do
      stub_request(:get, patron_url)
        .to_return(status: 400, body: responses[:not_found], headers: {})
      stub_request(:post, user_url)
        .to_return(status: 400, body: responses[:invalid_patron], headers: {})
      transaction = illiad_transaction.create_request
      expect(transaction).to be_blank
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "posts a transaction and also sends an email when the patron is not cleared" do
      stub_request(:post, transaction_url)
        .with(body: hash_including("Username" => "abc234", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "That One", "PhotoItemAuthor" => "Davis, Paul K.", "PhotoJournalTitle" => "100 decisive battles : from ancient times to the present", "PhotoItemPublisher" => "Santa Barbara, Calif: ABC-CLIO", "ISSN" => "9781576070758", "CallNumber" => "HF1131 .B485", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9935102073506421", "PhotoJournalVolume" => "",
                                   "PhotoJournalIssue" => nil, "ItemInfo3" => nil, "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1033410889", "DocumentType" => "Book", "PhotoArticleTitle" => nil))
        .to_return(status: 200, body: responses[:transaction_created], headers: {})
      stub_request(:post, transaction_note_url)
        .with(body: hash_including("Note" => "Digitization Request: Customer note"))
        .to_return(status: 200, body: responses[:note_created], headers: {})
      stub_request(:get, patron_url)
        .to_return(status: 200, body: responses[:not_cleared], headers: {})
      transaction = nil
      expect { transaction = illiad_transaction.create_request }.to change { ActionMailer::Base.deliveries.count }.by(1)
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Uncleared User Requesting Transaction")
      expect(email.html_part.body.to_s).to have_content('F - Faculty')
      requestable.each do |_key, value|
        expect(email.html_part.body.to_s).to have_content(value)
      end
      expect(transaction).not_to be_blank
      expect(transaction["Username"]).to eq('abc123')
      expect(transaction["TransactionNumber"]).to eq(1_093_806)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context "loan metdata mapper" do
    let(:metadata_mapper) { Requests::IlliadMetadata::Loan.new(patron: submission.patron, bib: submission.bib, item: submission.items.first) }

    describe '#create_request' do
      let(:user_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/Users" }
      let(:patron_url) { "#{user_url}/#{user_info.netid}" }
      let(:transaction_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction" }
      let(:transaction_note_url) { "#{illiad_transaction.illiad_api_base}/ILLiadWebPlatform/transaction/1093806/notes" }

      it "returns data when user is present" do
        stub_request(:get, patron_url)
          .to_return(status: 200, body: responses[:found], headers: {})
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "abc234", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Davis, Paul K.", "LoanTitle" => "100 decisive battles : from ancient times to the present", "LoanPublisher" => "Santa Barbara, Calif: ABC-CLIO", "ISSN" => "9781576070758", "CallNumber" => "HF1131 .B485", "CitedIn" => "https://catalog.princeton.edu/catalog/9935102073506421", "ItemInfo3" => "2019", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1033410889", "DocumentType" => "Book", "LoanPlace" => nil))
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url)
          .with(body: hash_including("Note" => "Loan Request"))
          .to_return(status: 200, body: responses[:note_created], headers: {})
        transaction = illiad_transaction.create_request
        expect(transaction).not_to be_blank
        expect(transaction["Username"]).to eq('abc123')
        expect(transaction["TransactionNumber"]).to eq(1_093_806)
      end
    end
  end
end
def format_label(label)
  label
end
