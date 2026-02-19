# frozen_string_literal: true
require 'rails_helper'

describe 'request form', vcr: { cassette_name: 'form_features', record: :none }, type: :feature, requests: true do
  include ActiveJob::TestHelper

  let(:mms_id) { '9994933183506421?mfhd=22558528920006421' }
  let(:thesis_id) { 'dsp01rr1720547' }
  let(:in_process_id) { '99117665883506421?mfhd=22707341710006421' }
  # going to need to review this with Mark to see if this example is good
  let(:recap_in_process_id) { '99114026863506421?mfhd=22753408610006421' }
  let(:on_order_id) { '99103251433506421?mfhd=22480270140006421' }
  let(:no_items_id) { '9941274093506421?mfhd=22690999210006421' }
  let(:on_shelf_no_items_id) { '993083506421?mfhd=22740191170006421' }
  let(:temp_item_id) { '4815239' }
  let(:temp_id_mfhd) { '5018096' }
  let(:mutiple_items) { '9979171923506421' }
  let(:the_senses) { '9951680203506421' }

  let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
  let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

  let(:valid_patron_response) { file_fixture('../bibdata_patron_response.json') }
  let(:valid_patron_no_barcode_response) { file_fixture('../bibdata_patron_no_barcode_response.json') }
  let(:valid_barcode_patron_response) { file_fixture('../bibdata_patron_response_barcode.json') }
  let(:valid_patron_no_campus_response) { file_fixture('../bibdata_patron_response_no_campus.json') }
  let(:valid_graduate_student_no_campus_response) { file_fixture('../bibdata_patron_response_graduate_no_campus.json') }
  let(:invalid_patron_response) { file_fixture('../bibdata_not_found_patron_response.json') }
  let(:valid_patron_response_no_ldap) { file_fixture('../bibdata_patron_response_no_ldap.json') }
  let(:affiliate_patron_response) { file_fixture('../bibdata_patron_affiliate_response.json') }

  let(:responses) do
    {
      transaction_created: '{"TransactionNumber":1093806,"Username":"abc123","RequestType":"Article","PhotoArticleAuthor":null,"PhotoJournalTitle":null,"PhotoItemPublisher":null,"LoanPlace":null,"LoanEdition":null,"PhotoJournalTitle":"Test Title","PhotoJournalVolume":"21","PhotoJournalIssue":"4","PhotoJournalMonth":null,"PhotoJournalYear":"2011","PhotoJournalInclusivePages":"165-183","PhotoArticleAuthor":"Williams, Joseph; Woolwine, David","PhotoArticleTitle":"Test Article","CitedIn":null,"CitedTitle":null,"CitedDate":null,"CitedVolume":null,"CitedPages":null,"NotWantedAfter":null,"AcceptNonEnglish":false,"AcceptAlternateEdition":true,"ArticleExchangeUrl":null,"ArticleExchangePassword":null,"TransactionStatus":"Awaiting Request Processing","TransactionDate":"2020-06-15T18:34:44.98","ISSN":"XXXXX","ILLNumber":null,"ESPNumber":null,"LendingString":null,"BaseFee":null,"PerPage":null,"Pages":null,"DueDate":null,"RenewalsAllowed":false,"SpecIns":null,"Pieces":null,"LibraryUseOnly":null,"AllowPhotocopies":false,' \
                          '"LendingLibrary":null,"ReasonForCancellation":null,"CallNumber":null,"Location":null,"Maxcost":null,"ProcessType":"Borrowing","ItemNumber":null,"LenderAddressNumber":null,"Ariel":false,"Patron":null,"PhotoItemAuthor":null,"PhotoItemPlace":null,"PhotoItemPublisher":null,"PhotoItemEdition":null,"DocumentType":null,"InternalAcctNo":null,"PriorityShipping":null,"Rush":"Regular","CopyrightAlreadyPaid":"Yes","WantedBy":null,"SystemID":"OCLC","ReplacementPages":null,"IFMCost":null,"CopyrightPaymentMethod":null,"ShippingOptions":null,"CCCNumber":null,"IntlShippingOptions":null,"ShippingAcctNo":null,"ReferenceNumber":null,"CopyrightComp":null,"TAddress":null,"TAddress2":null,"TCity":null,"TState":null,"TZip":null,"TCountry":null,"TFax":null,"TEMailAddress":null,"TNumber":null,"HandleWithCare":false,"CopyWithCare":false,"RestrictedUse":false,"ReceivedVia":null,"CancellationCode":null,"BillingCategory":null,"CCSelected":null,"OriginalTN":null,"OriginalNVTGC":null,"InProcessDate":null,' \
                          '"InvoiceNumber":null,"BorrowerTN":null,"WebRequestForm":null,"TName":null,"TAddress3":null,"IFMPaid":null,"BillingAmount":null,"ConnectorErrorStatus":null,"BorrowerNVTGC":null,"CCCOrder":null,"ShippingDetail":null,"ISOStatus":null,"OdysseyErrorStatus":null,"WorldCatLCNumber":null,"Locations":null,"FlagType":null,"FlagNote":null,"CreationDate":"2020-06-15T18:34:44.957","ItemInfo1":null,"ItemInfo2":null,"ItemInfo3":null,"ItemInfo4":null,"SpecIns":null,"SpecialService":"Digitization Request: ","DeliveryMethod":null,"Web":null,"PMID":null,"DOI":null,"LastOverdueNoticeSent":null,"ExternalRequest":null}',
      note_created: '{"Message":"An error occurred adding note to transaction 1093946"}'
    }
  end

  before do
    stub_delivery_locations
  end

  context 'all patrons' do
    describe 'When unauthenticated patron visits a request item', js: true do
      it "displays two authentication options" do
        stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
        visit '/requests/9999443553506421?mfhd=22743365320006421'
        expect(page).to have_content(I18n.t('blacklight.login.netid_login_msg'))
        expect(page).to have_content(I18n.t('blacklight.login.alma_login_msg'))
      end
    end
  end

  context 'a Princeton CAS user' do
    let(:user) { FactoryBot.create(:user) }

    let(:recap_params) do
      {
        Bbid: "9994933183506421",
        barcode: "23131438400006421",
        item: "7303228",
        lname: "Student",
        delivery: "p",
        pickup: "PN",
        startpage: "",
        endpage: "",
        email: "a@b.com",
        volnum: "",
        issue: "",
        aauthor: "",
        atitle: "",
        note: ""
      }
    end

    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=false")
        .to_return(status: 200, body: valid_patron_response_no_ldap, headers: {})
      login_as user
    end

    after do
      clear_enqueued_jobs
    end

    describe 'an item with no #show_pick_up_service_options' do
      # This is testing specifically issue https://github.com/pulibrary/orangelight/issues/3498
      # It does not test requesting it fixes a display issue.
      it 'does not display html as a string' do
        stub_catalog_raw(bib_id: '993569343506421')
        stub_single_holding_location('plasma$nb')
        stub_availability_by_holding_id(bib_id: '993569343506421', holding_id: '22693661550006421')
        visit('requests/993569343506421?aeon=false&mfhd=22693661550006421')
        within('#request_user_supplied_22693661550006421') do
          page.find("#requestable__delivery_mode_22693661550006421_print").click
          expect(page).to have_selector('#fields-print__22693661550006421')
          # This element should be rendered as html, not plain text
          expect(page).not_to have_text('fields-print__22693661550006421_card')
          expect(page).to have_selector('#fields-print__22693661550006421_card')
        end
      end
    end

    describe 'When visiting an Alma ID as a CAS User' do
      let(:good_response) { file_fixture('../scsb_request_item_response.json') }
      it 'Shows a ReCAP PUL item that is at "preservation and conservation" as a Resource Sharing partner request' do
        stub_single_holding_location 'recap$pa'
        stub_illiad_patron
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Zhongguo xin li xue hui", "LoanTitle" => "Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science", "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "BF8.C5 H76", "CitedIn" => "https://catalog.princeton.edu/catalog/9941150973506421", "ItemInfo3" => "no.217-218", "ItemInfo4" => nil, "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url)
          .with(body: hash_including("Note" => "Loan Request"))
          .to_return(status: 200, body: responses[:note_created], headers: {})
        stub_scsb_availability(bib_id: "9941150973506421", institution_id: "PUL", barcode: '32101099680850', item_availability_status: 'Not Available')
        stub_catalog_raw bib_id: '9941150973506421'
        visit 'requests/9941150973506421?mfhd=22492663380006421&source=pulsearch'
        expect(page).to have_content 'Unavailable'
        check "requestable_selected_23492663220006421"
        expect(page).to have_content 'Request via Partner Library'
        expect(page).to have_content 'Pick-up location: Firestone Library'
        expect(page).to have_title("Request: Xin li ke xue = Journal of psychological science")
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Partner Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it 'allow CAS patrons to request an available ReCAP PUL item.' do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: "", bibId: "9994933183506421", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                     requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
          .to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, Requests.config[:scsb_base])
          .with(headers: { 'Accept' => '*/*' })
          .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
        stub_request(:post, "#{Alma.configuration.region}/almaws/v1/bibs/9994933183506421/holdings/22558528920006421/items/23558528910006421/requests?user_id=960594184")
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 200, body: file_fixture("../alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        visit "/requests/#{mms_id}"
        expect(page).to have_content 'Electronic Delivery'
        # some weird issue with this and capybara examining the page source shows it is there.
        expect(page).to have_selector '#request_user_barcode', visible: :hidden
        choose('requestable__delivery_mode_23558528910006421_print') # chooses 'print' radio button
        select('Firestone Library', from: 'requestable__pick_up_23558528910006421')
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        expect(page).to have_content I18n.t("requests.submit.recap_success")
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("ʻAwāṭif madfūnah")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it 'allows CAS patrons to request In-Process items that reside in a PUL library and can only be delivered to that library' do
        stub_catalog_raw bib_id: '99117665883506421'
        visit "/requests/#{in_process_id}"
        expect(page).to have_content 'In Process'
        expect(page).to have_content 'Pick-up location: East Asian Library'
        expect(page).to have_button('Request this Item', disabled: false)
        click_button 'Request this Item'
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
      end
      # In-Process -> it's waiting to be cataloged in a PUL library and then shipped to RECAP
      it 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere' do
        stub_catalog_raw bib_id: '99114026863506421'
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "99114026863506421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
        visit "/requests/#{recap_in_process_id}"
        expect(page).to have_content 'In Process'
        expect(page.find(:css, ".request--availability").text).to eq("Unavailable")
        select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up_23753408600006421')
        select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up_23753408600006421')
        select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up_23753408600006421')
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("In Process Request")
        expect(email.to).to eq(["fstcirc@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("Konteneryzacja w PRL")
        expect(confirm_email.subject).to eq("In Process Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Konteneryzacja w PRL")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end
      # On-order -> it hasn't been delivered to a Princeton library yet.
      it 'allows CAS patrons to request On-Order items' do
        stub_catalog_raw bib_id: '99103251433506421'
        visit "/requests/#{on_order_id}"
        expect(page).to have_button('Request Selected Items', disabled: false)
        check 'requestable_selected_23480270130006421'
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.on_order_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Order Request")
        expect(email.to).to eq(["fstcirc@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("Jahrbuch Praktische Philosophie in globaler Perspektive = Yearbook practical philosophy in a global perspective")
        expect(confirm_email.subject).to eq("On Order Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Jahrbuch Praktische Philosophie in globaler Perspektive = Yearbook practical philosophy in a global perspective")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end
      # This is an example item that was in incorrect state.
      # It has changed. We still want to keep this scenario in case it happens again.
      it 'allows CAS patrons to request a ReCAP PUL record that has no item data' do
        stub_single_holding_location 'recap$pa'
        visit "/requests/99113283293506421?mfhd=22750642660006421"
        check('requestable_selected', exact: true)
        fill_in 'requestable[][user_supplied_enum]', with: 'Some Volume'
        expect(page).to have_button('Request this Item', disabled: false)
      end

      it 'allows CAS patrons to request a PUL record that has no item data' do
        visit "/requests/#{on_shelf_no_items_id}"
        choose('requestable__delivery_mode_22740191170006421_print') # chooses 'print' radio button
        expect(page).to have_content "Pick-up location: Firestone Library"
        expect(page).to have_content "Requests for pick-up typically take 2 business days to process."
      end
      it 'allows CAS patrons to request an on_shelf record' do
        stub_alma_hold_success('9912636153506421', '22557213410006421', '23557213400006421', '960594184')

        visit "requests/9912636153506421?mfhd=22557213410006421"
        expect(page).to have_content 'Pick-up location: Firestone Library'
        choose('requestable__delivery_mode_23557213400006421_print') # chooses 'print' radio button
        expect(page).to have_content 'Pick-up location: Firestone Library'
        expect(page).to have_content 'Electronic Delivery'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Shelf Request (FIRESTONE$STACKS) PR3187 .L443 1951")
        expect(email.to).to eq(["fstpage@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("John Webster; a critical study")
        expect(email.html_part.body.to_s).not_to have_content("9912636153506421") # does not show detailed metadata
        expect(confirm_email.subject).to eq("Firestone Library Pick-up Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("John Webster; a critical study")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it 'shows the CAS patron a duplication message when they request an item more than once' do
        stub_alma_hold('9912636153506421', '22557213410006421', '23557213400006421', '960594184', status: 200, fixture_name: "alma_hold_error_response.json")

        visit "requests/9912636153506421?mfhd=22557213410006421"
        expect(page).to have_content 'Pick-up location: Firestone Library'
        choose('requestable__delivery_mode_23557213400006421_print') # chooses 'print' radio button
        expect(page).to have_content 'Pick-up location: Firestone Library'
        expect(page).to have_content 'Electronic Delivery'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(page).to have_content 'You have sent a duplicate request to Alma for this item'
      end
      it 'allows CAS patrons to request a PUL electronic document delivery (EDD) ReCAP item' do
        stub_single_holding_location 'recap$pa'
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: "", bibId: "9999443553506421", callNumber: "DT549 .E274q Oversize", chapterTitle: "ABC", deliveryLocation: "PA", emailAddress: "a@b.com", endPage: "", issue: "",
                                     itemBarcodes: ["32101098722844"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "L'écrivain, magazine litteraire trimestriel", username: "jstudent", volume: "2016"))
          .to_return(status: 200, body: good_response, headers: {})
        stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
        visit '/requests/9999443553506421?mfhd=22743365320006421'
        expect(page).to have_content 'Electronic Delivery'
        select('Firestone Library', from: 'requestable__pick_up_23743365310006421')
        choose('requestable__delivery_mode_23743365310006421_edd') # chooses 'edd' radio button
        expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
        fill_in "Article/Chapter Title", with: "ABC"
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        expect(page).to have_content 'Request submitted'
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("L'écrivain, magazine litteraire trimestriel")
      end

      it 'allows CAS patrons to request a Forrestal Annex item' do
        stub_alma_hold_success('999455503506421', '22642306790006421', '23642306760006421', '960594184')
        visit '/requests/999455503506421?mfhd=22642306790006421'
        choose('requestable__delivery_mode_23642306760006421_print') # chooses 'print' radio button
        expect(page).to have_content 'Item offsite at Forrestal Annex. Requests for pick-up'
        expect(page).to have_content 'Electronic Delivery'
        # Confirm that all the following options are in the drop-down
        select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up_23642306760006421')
        select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up_23642306760006421')
        select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up_23642306760006421')
        select('Firestone Library', from: 'requestable__pick_up_23642306760006421')
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content 'Request submitted'
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("Annex Request")
        expect(email.to).to eq(["forranx@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
        expect(confirm_email.subject).to eq("Annex Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("A tale of cats and mice of Obeyd of Záákán")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        expect(stub_alma_hold_success('999455503506421', '22642306790006421', '23642306760006421', '960594184')).to have_been_requested
      end

      it 'allows CAS patrons to request electronic delivery of a Forrestal item' do
        stub_catalog_raw(bib_id: '9956562643506421')
        stub_availability_by_holding_id(bib_id: '9956562643506421', holding_id: '22700125400006421')
        stub_illiad_patron
        stub_request(:post, transaction_url)
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url)
          .to_return(status: 200, body: responses[:note_created], headers: {})
        visit '/requests/9956562643506421?mfhd=22700125400006421'
        expect(page).to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Electronic Delivery'
        choose('requestable__delivery_mode_23700125390006421_edd') # chooses 'electronic delivery' radio button
        fill_in "Title", with: "my stuff"
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, transaction_url)).to have_been_made
      end

      it 'allows CAS patrons to make an electronic document delivery request for a Lewis ReCAP item' do
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_scsb_availability(bib_id: "9970533073506421", institution_id: "PUL", barcode: '32101051217659')
        stub_request(:post, scsb_url)
          .to_return(status: 200, body: good_response, headers: {})
        visit '/requests/9970533073506421?mfhd=22667391160006421'
        expect(page).to have_content 'Available for In Library Use'
        expect(page).to have_content 'Electronic Delivery'
        choose('requestable__delivery_mode_23667391150006421_edd') # chooses 'edd' radio button
        expect(page).to have_content 'Pick-up location: Lewis Library'
        fill_in "Title", with: "my stuff"
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        expect(page).to have_content 'Request submitted'
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
      end

      it 'allows CAS patrons to request a Lewis physical item' do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_alma_hold_success('9970533073506421', '22667391180006421', '23667391170006421', '960594184')
        visit '/requests/9970533073506421?mfhd=22667391180006421'
        expect(page).to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Electronic Delivery'
        choose 'requestable__delivery_mode_23667391170006421_print'
        expect(page).to have_content 'Pick-up location: Lewis Library'
        check 'requestable_selected_23667391170006421'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content 'Item has been requested for pick-up'
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Shelf Request (LEWIS$STACKS) QA646 .A44 2012")
        expect(email.to).to eq(["lewislib@princeton.edu"])
        expect(email.cc).to be_nil
        expect(email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
        expect(confirm_email.subject).to eq("Lewis Library Pick-up Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_nil
        expect(confirm_email.html_part.body.to_s).to have_content("The decomposition of global conformal invariants")
      end

      it 'allows CAS patrons to ask for digitization on non circulating items' do
        visit '/requests/9995948403506421?mfhd=22500774400006421'
        expect(page).to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Pick-up location: Lewis Library'
        expect(page).to have_css '.submit--request'
      end

      it 'shows a fill in form if the item is an enumeration (Journal ect.) and choose a print copy' do
        visit 'requests/99105746993506421?mfhd=22547424510006421'
        choose('requestable__delivery_mode_22547424510006421_print')
        expect(page).to have_content 'Pick-up location: Firestone Library'
        expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
        expect(page).to have_content 't. 2, no 2 (2018 )' # include enumeration and chron
        expect(page).to have_content 't. 3, no 2 (2019 )' # include enumeration and chron
        expect(page).to have_field('requestable_user_supplied_enum_22547424510006421')
        expect(page).to have_selector('label[for=requestable_user_supplied_enum_22547424510006421]')
        within(".user-supplied-input") do
          check('requestable_selected')
        end
        fill_in "requestable_user_supplied_enum_22547424510006421", with: "ABC ZZZ"
        choose('requestable__delivery_mode_22547424510006421_print') # choose the print radio button
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Shelf Request for Firestone Library")
        expect(email.to).to eq(["fstpage@princeton.edu"])
        expect(email.cc).to be_nil
        expect(email.html_part.body.to_s).to have_content("ABC ZZZ")
        expect(confirm_email.subject).to eq("On Shelf Request (FIRESTONE$STACKS) R131.A1 M38")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_nil
        expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
      end

      it 'shows a fill in form if the item is an enumeration (Journal etc.) and choose a electronic copy' do
        stub_illiad_patron
        stub_request(:post, transaction_url)
          .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => "", "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/99105746993506421", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ",
                                     "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
          .to_return(status: 200, body: responses[:transaction_created], headers: {})
        stub_request(:post, transaction_note_url)
          .to_return(status: 200, body: responses[:note_created], headers: {})
        visit 'requests/99105746993506421?mfhd=22547424510006421'
        expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
        within(".user-supplied-input") do
          check('requestable_selected')
        end
        fill_in "requestable_user_supplied_enum_22547424510006421", with: "ABC ZZZ"
        choose('requestable__delivery_mode_22547424510006421_edd') # choose the print radio button
        within("#fields-eed__22547424510006421") do
          fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
        end
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, transaction_url)).to have_been_made
        expect(a_request(:post, transaction_note_url)).to have_been_made
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_nil
        expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it "shows items in the Architecture Library as available" do
        stub_alma_hold_success('99117876713506421', '22561348800006421', '23561348790006421', '960594184')
        visit '/requests/99117876713506421?mfhd=22561348800006421'
        # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Pick-up location: Architecture Library'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Shelf Request (ARCH$STACKS) NA1585.A23 S7 2020")
        expect(email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
        expect(confirm_email.subject).to eq("Architecture Library Pick-up Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("Your request for this item has been received. Once we complete our processing, you'll receive an email stating that the book is available for pick-up. Please note that if you need this item quickly, you can retrieve the book from the stacks and bring it to circulation to check out.")
        expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
      end

      it "allows requests of ReCAP pick-up only items" do
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_scsb_availability(bib_id: "99115783193506421", institution_id: "PUL", barcode: '32101108035435')
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: nil, bibId: "99115783193506421", callNumber: "DVD", chapterTitle: nil, deliveryLocation: "PA", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["32101108035435"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "Chernobyl : a 5-part miniseries", username: "jstudent", volume: nil))
          .to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, "#{Alma.configuration.region}/almaws/v1/bibs/99115783193506421/holdings/22534122440006421/items/23534122430006421/requests?user_id=960594184")
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 200, body: file_fixture("../alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        visit '/requests/99115783193506421?mfhd=22534122440006421'
        expect(page).not_to have_content 'Item is not requestable.'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'Item off-site at ReCAP facility. Request for delivery in 1-2 business days.'
        select('Firestone Library', from: 'requestable__pick_up_23534122430006421')
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("Your request for this item has been received. Once we complete our processing, you'll receive an email stating that the book is available for pick-up.")
        expect(confirm_email.html_part.body.to_s).to have_content("Chernobyl : a 5-part miniseries")
      end

      context 'Resource Sharing request via Illiad' do
        it 'sends requests directly to Illiad' do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_catalog_raw bib_id: '9917887963506421'
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check('requestable_selected_23503918390006421')
          expect(page.find_field('requestable[][type]', type: :hidden).value).to eq('ill')
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Most requests will arrive within two weeks")
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
        end
      end
      context 'Annex with item data' do
        it 'an Annex item with user supplied information creates Annex emails' do
          patron = instance_double(Requests::Patron, core_patron_group?: true, affiliate_patron_group?: false)
          allow(patron).to receive(:user).and_return(user)
          allow(patron).to receive(:errors).and_return([])
          allow(patron).to receive(:guest?).and_return(false)
          allow(patron).to receive(:eligible_for_library_services?).and_return(true)
          allow(patron).to receive(:last_name).and_return('Cute')
          allow(patron).to receive(:first_name).and_return('Aspen')
          item_double = instance_double(Requests::Item, temp_loc_other_than_resource_sharing?: false)
          holding_double = instance_double(Requests::Holding, mfhd_id: 'mfhd123')
          requestable = instance_double(Requests::Requestable,
                                        holding: holding_double,
                                        bib: { id: 'bibid123' },
                                        id: 'requestable_id',
                                        item: item_double,
                                        title: 'Trump : the art of the comeback',
                                        location: { code: 'annex', label: 'Annex' },
                                        call_number: 'ANNEX 1234',
                                        services: [],
                                        eligible_for_library_services?: true,
                                        annex?: true,
                                        item_data?: true,
                                        charged?: false,
                                        aeon?: false,
                                        in_process?: false,
                                        on_order?: false,
                                        alma_managed?: true,
                                        recap?: false,
                                        recap_pf?: false,
                                        held_at_marquand_library?: false,
                                        use_statement: nil,
                                        item_type_non_circulate?: false,
                                        partner_holding?: false,
                                        pick_up_location_code: 'firestone',
                                        item_type: 'book',
                                        enum_value: nil,
                                        cron_value: nil,
                                        temp_loc_other_than_resource_sharing?: false,
                                        on_reserve?: false,
                                        enumerated?: false,
                                        collection_code: nil,
                                        status: 'Available',
                                        status_label: 'Available',
                                        barcode?: true,
                                        barcode: '123456789',
                                        preservation_conservation?: false,
                                        aeon_request_url: nil,
                                        holding_library_in_library_only?: false,
                                        holding_library: nil,
                                        circulates?: true,
                                        recap_edd?: false,
                                        item_location_code: nil,
                                        item?: true,
                                        use_restriction?: false,
                                        library_code: 'annex',
                                        illiad_request_parameters: nil,
                                        location_label: 'Annex',
                                        patron: patron,
                                        ill_eligible?: false,
                                        scsb_in_library_use?: false,
                                        pick_up_locations: ['firestone'],
                                        on_shelf?: true,
                                        illiad_request_url: nil,
                                        available?: true,
                                        cul_avery?: false,
                                        cul_music?: false)
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Requests::Router).to receive(:eligibility_checks).and_return([
                                                                                               Requests::ServiceEligibility::Annex::Pickup.new(requestable: requestable, patron: patron)
                                                                                             ])
          # rubocop:enable RSpec/AnyInstance
          visit '/requests/9922868943506421?mfhd=22692156940006421'

          expect(page).to have_field 'requestable_selected', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_22692156940006421'
          within('#request_user_supplied_22692156940006421') do
            check('requestable_selected', exact: true)
            fill_in 'requestable_user_supplied_enum_22692156940006421', with: 'test'
          end
          expect(page).to have_content 'Physical Item Delivery'
          choose 'requestable__delivery_mode_22692156940006421_print'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up_22692156940006421')
          expect do
            click_button 'Request Selected Items'
          end.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t('requests.submit.annex_success')
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Annex Request")
          expect(email.to).to eq(["forranx@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("Birth control news")
          expect(email.html_part.body.to_s).to have_content("test")
          expect(email.text_part.body.to_s).to have_content("test")
          expect(confirm_email.subject).to eq("Annex Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Birth control news")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end
      end

      it 'allows an in process item to be requested' do
        stub_catalog_raw bib_id: '99117665883506421'
        visit "/requests/#{in_process_id}"
        expect(page).to have_content 'In Process materials are typically available in several business days'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("In Process Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("In Process materials can typically be picked up at the Circulation Desk of your choice in several business days")
        expect(confirm_email.html_part.body.to_s).to have_content("Gai zao jiao yu xue")
        in_process_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        expect(in_process_email.subject).to eq("In Process Request")
        expect(in_process_email.html_part.body.to_s).to have_content("Gai zao jiao yu xue")
        expect(in_process_email.to).to eq(["fstcirc@princeton.edu"])
        expect(in_process_email.cc).to be_blank
      end

      context 'disavowed Illiad user' do
        it 'allows a non circulating item with not item data to be digitized to be requested, but then errors' do
          stub_illiad_patron(disavowed: true)
          visit '/requests/9941274093506421?mfhd=22690999210006421'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_22690999210006421_edd') # chooses 'edd' radio button
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content "You no longer have an active account and may not make digitization requests."
          error_email = ActionMailer::Base.deliveries.last
          expect(error_email.subject).to eq("Request Service Error")
          expect(error_email.to).to eq(["docdel@princeton.edu"])
        end
      end

      it "allows a Columbia item to be picked up or digitized" do
        stub_scsb_availability(bib_id: "1000060", institution_id: "CUL", barcode: 'CU01805363')
        stub_catalog_raw(bib_id: 'SCSB-2879197', type: 'scsb')
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: "", bibId: "SCSB-2879197", callNumber: "PG3479.3.I84 Z778 1987g", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU01805363"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva", username: "jstudent", volume: ""))
          .to_return(status: 200, body: good_response, headers: {})
        stub_single_holding_location 'scsbcul'

        visit '/requests/SCSB-2879197'
        expect(page).to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Electronic Delivery'
        choose('requestable__delivery_mode_4497908_print') # chooses 'print' radio button
        expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
        expect(page).to have_content 'ReCAP PG3479.3.I84 Z778 1987g'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("Your request for this item has been received. Once we complete our processing, you'll receive an email stating that the book is available for pick-up.")
        expect(confirm_email.html_part.body.to_s).to have_content("Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it "Display only the 'In Library Use' option for an in library use only ReCAP Partner item" do
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: nil, bibId: "SCSB-8953469", callNumber: "ReCAP 18-69309", chapterTitle: nil, deliveryLocation: "QX", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["33433121206696"], itemOwningInstitution: "NYPL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "1955-1968 : gli artisti italiani alle Documenta di Kassel", username: "jstudent", volume: nil))
          .to_return(status: 200, body: good_response, headers: {})
        stub_scsb_availability(bib_id: ".b215204128", institution_id: "NYPL", barcode: '33433121206696')
        stub_catalog_raw(bib_id: 'SCSB-8953469', type: 'scsb')
        visit 'requests/SCSB-8953469'
        expect(page).to have_content 'Available for In Library'
        expect(page).not_to have_content 'Electronic Delivery'
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(a_request(:post, scsb_url)).to have_been_made
        expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("955-1968 : gli artisti italiani alle Documenta di Kassel")
      end

      it 'Shows a PUL ReCAP item that has not made it to ReCAP yet as available for On Order request' do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "99123340993506421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
        visit '/requests/99123340993506421?mfhd=22569931350006421'
        expect(page).to have_content 'Unavailable'
        select('Firestone Library', from: 'requestable__pick_up_23896622240006421')
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Order Request")
        expect(email.to).to eq(["fstcirc@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("Ḍaḥāyā al-zawāj")
        expect(confirm_email.subject).to eq("On Order Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Ḍaḥāyā al-zawāj")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it "Delivers ReCAP Partner in library use music items only to Mendel Music Library" do
        # Why does stub use the wrong bib_id?
        stub_scsb_availability(bib_id: "14577462", institution_id: "CUL", barcode: 'MR00393223')
        stub_single_holding_location 'scsbcul'
        visit '/requests/SCSB-9726156'
        expect(page).to have_content 'Available for In Library Use'
        expect(page).to have_content 'Pick-up location: Mendel Music Library'
      end

      it "a ReCAP Partner item from Harvard that is restricted to in library use at Marquand" do
        scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
        # Why does stub use the wrong bib_id?
        stub_scsb_availability(bib_id: "990143653400203941", institution_id: "HL", barcode: '32044136602687')
        stub_request(:post, scsb_url)
          .with(body: hash_including(author: "", bibId: "SCSB-9919951", callNumber: "N5230.M62 R39 2014", chapterTitle: "", deliveryLocation: "PJ", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32044136602687"], itemOwningInstitution: "HL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Razón de ser : obras emblemáticas de la Colección Carrillo Gil : Orozco, Rivera, Siqueiros, Paalen, Gerzso", username: "jstudent", volume: ""))
          .to_return(status: 200, body: good_response, headers: {})
        visit '/requests/SCSB-9919951'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'Available for In Library Use'
        expect(page).to have_content('Pick-up location: Marquand Library')
        expect(page).to have_content 'ReCAP N5230.M62 R39 2014'
      end

      it "Allows On Order Princeton ReCAP Items to be Requested" do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "99125378834306421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
        visit '/requests/99125378834306421?mfhd=22897184810006421'
        expect(page).to have_content 'On Order books have not yet been received. Place a request to be notified when this item has arrived and is ready for your pick-up.'
      end

      it 'Request an enumerated on campus item correctly' do
        stub_alma_hold_success('9973397793506421', '22541187250006421', '23541187200006421', '960594184')
        visit '/requests/9973397793506421?mfhd=22541187250006421'
        expect(page).to have_content "Han'guk hyŏndaesa sanch'aek"
        check('requestable_selected_23541187200006421')
        choose('requestable__delivery_mode_23541187200006421_print')
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.on_shelf_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("On Shelf Request (EASTASIAN$CJK) DS923.25 .K363 2011")
        expect(email.to).to eq(["gestcirc@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("Han'guk hyŏndaesa sanch'aek. No Mu-hyŏn sidae ŭi myŏngam")
        expect(email.html_part.body.to_s).to have_content("vol.5")
        expect(email.text_part.body.to_s).to have_content("vol.5")
        expect(confirm_email.subject).to eq("East Asian Library Pick-up Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Han'guk hyŏndaesa sanch'aek. No Mu-hyŏn sidae ŭi myŏngam")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it 'Request a Forrestal Annex In Library Use book correctly' do
        stub_alma_hold_success('9941347943506421', '22560381400006421', '23560381360006421', '960594184')
        visit 'requests/9941347943506421?mfhd=22560381400006421'
        expect(page).to have_content "Er ru ting Qun fang pu : [san shi juan]"
        check('requestable_selected_23560381360006421')
        choose('requestable__delivery_mode_23560381360006421_in_library')
        select 'Firestone Library', from: 'requestable__pick_up_23560381360006421'
        expect do
          click_button 'Request Selected Items'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.annex_in_library_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
        expect(email.to).to eq(["forranx@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("Er ru ting Qun fang pu : [san shi juan]")
        expect(email.html_part.body.to_s).to have_content("vol.9-16")
        expect(email.text_part.body.to_s).to have_content("vol.9-16")
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["a@b.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("Er ru ting Qun fang pu : [san shi juan]")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      describe 'Request a temp holding item' do
        before do
          stub_illiad_patron
          stub_alma_hold_success('99105816503506421', '22514405160006421', '23514405150006421', '960594184')
          stub_catalog_raw(bib_id: '99105816503506421')
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Zhongguo xin li xue hui", "LoanTitle" => "Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science", "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "BF8.C5 H76", "CitedIn" => "https://catalog.princeton.edu/catalog/9941150973506421", "ItemInfo3" => "no.217-218", "ItemInfo4" => nil, "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
        end
        it 'with an electronic delivery' do
          visit 'requests/99105816503506421?mfhd=22514405160006421'
          expect(page).to have_content "SOS brutalism : a global survey"
          expect(page).to have_content 'Elser, Oliver'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content "Architecture Library- Librarian's Office NA682.B7 S673 2017b"
          expect(page).to have_content 'Available'
          expect(page).to have_content 'vol.1'
          check('requestable_selected_23514405150006421')
          choose('requestable__delivery_mode_23514405150006421_edd')
          fill_in 'requestable__edd_art_title_23514405150006421', with: 'some text'
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
        end
        it 'with a Physical delivery' do
          visit 'requests/99105816503506421?mfhd=22514405160006421'
          expect(page).to have_content "SOS brutalism : a global survey"
          expect(page).to have_content 'Elser, Oliver'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content "Architecture Library- Librarian's Office NA682.B7 S673 2017b"
          expect(page).to have_content 'Available'
          expect(page).to have_content 'vol.1'
          check('requestable_selected_23514405150006421')
          choose('requestable__delivery_mode_23514405150006421_print')
          expect(page).to have_content 'Pick-up location: Architecture Library'
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end

      describe 'Request a temp holding item from Resource Sharing - RES_SHARE$IN_RS_REQ' do
        ## TODO check to see with Circ/ATT team if this is still a "real" scenario. d
        before do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_alma_hold('9991807103506421', '22696270550006421', '23696270540006421', '960594184', status: 200, fixture_name: "availability_response_9991807103506421.json")
          stub_catalog_raw(bib_id: '9991807103506421')
        end
        it 'request via partner library' do
          visit 'requests/9991807103506421?mfhd=22696270550006421'
          expect(page).to have_content "Towards the critique of violence : Walter Benjamin and Giorgio Agamben"
          expect(page).to have_content 'Moran, Brendan P.'
          expect(page).to have_content 'Firestone Library - Stacks HM886 .T69 2015'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content "Pick-up location: Firestone Library"
          expect(page).to have_content "Unavailable"
          expect(page).not_to have_content "Resource Sharing Request"
          check('requestable_selected_23696270540006421')
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Your request was submitted'
        end
      end
    end

    it 'Request a Forrestal Annex with no items will email annex' do
      stub_alma_hold_success('9941347943506421', '22560381400006421', '23560381360006421', '960594184')
      visit 'requests/9941347943506421?mfhd=22560381400006421'
      expect(page).to have_content "Er ru ting Qun fang pu : [san shi juan]"
      check('requestable_selected_23560381360006421')
      choose('requestable__delivery_mode_23560381360006421_in_library')
      select 'Firestone Library', from: 'requestable__pick_up_23560381360006421'
      expect do
        click_button 'Request Selected Items'
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(page).to have_content I18n.t("requests.submit.annex_in_library_success")
      email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      confirm_email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
      expect(email.to).to eq(["forranx@princeton.edu"])
      expect(email.cc).to be_blank
      expect(email.html_part.body.to_s).to have_content("Er ru ting Qun fang pu : [san shi juan]")
      expect(email.html_part.body.to_s).to have_content("vol.9-16")
      expect(email.text_part.body.to_s).to have_content("vol.9-16")
      expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
      expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
      expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
      expect(confirm_email.to).to eq(["a@b.com"])
      expect(confirm_email.cc).to be_blank
      expect(confirm_email.html_part.body.to_s).to have_content("Er ru ting Qun fang pu : [san shi juan]")
      expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
    end

    it 'Handles a bad mfhd without system error' do
      visit 'requests/998574693506421?mfhd=abc123'
      expect(page).to have_content "Science"
    end

    it 'has firestone as the resource sharing delivery location' do
      visit 'requests/99123713303506421?mfhd=22668310350006421'
      expect(page).to have_content 'Reconstructions : architecture and Blackness in America'
      expect(page).to have_content 'Request via Partner Library'
      expect(page).to have_content 'Pick-up location: Firestone Library'
    end
  end

  context 'A Princeton net ID user without an Alma record' do
    let(:user) { FactoryBot.create(:user) }
    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 404, body: invalid_patron_response, headers: {})
      login_as user
    end

    describe 'Visits a request page', js: true do
      it 'Tells the user their patron record is not available' do
        stub_scsb_availability bib_id: '99117809653506421', institution_id: 'PUL', barcode: '32101106347378'
        visit "/requests/99117809653506421?mfhd=22613352460006421"
        expect(a_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")).to have_been_made
        expect(page).to have_content(I18n.t("requests.account.auth_user_lookup_fail"))
      end
    end
  end

  context 'a Princeton net ID user without a barcode' do
    let(:user) { FactoryBot.create(:user) }
    let(:in_process_id) { '99124449473506421?mfhd=22664801380006421' }
    let(:recap_in_process_id) { '99114026863506421?mfhd=22753408610006421' }

    let(:recap_params) do
      {
        Bbid: "9994933183506421",
        item: "23131438400006421",
        lname: "Student",
        delivery: "p",
        pickup: "PN",
        startpage: "",
        endpage: "",
        email: "a@b.com",
        volnum: "",
        issue: "",
        aauthor: "",
        atitle: "",
        note: ""
      }
    end

    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_no_barcode_response, headers: {})
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=false")
        .to_return(status: 200, body: valid_patron_response_no_ldap, headers: {})
      login_as user
    end

    describe 'When visiting an Alma ID as a user without a barcode' do
      it 'disallows access to request an available ReCAP item.' do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_catalog_raw bib_id: '9994933183506421'
        visit "/requests/#{mms_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to In Process items' do
        visit "/requests/#{in_process_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access for In Process recap items' do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability bib_id: '99114026863506421', institution_id: 'PUL', barcode: 'fake-barcode'
        stub_catalog_raw bib_id: '99114026863506421'
        visit "/requests/#{recap_in_process_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access for On-Order recap items' do
        stub_catalog_raw bib_id: '99103251433506421'
        visit "/requests/#{on_order_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to a record that has no item data' do
        visit "/requests/#{no_items_id}"
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to a ReCAP record that has no item data to be digitized' do
        visit "/requests/993083506421?mfhd=22740191180006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to request an on-campus item' do
        stub_illiad_patron
        visit "/requests/9997708113506421?mfhd=22729045760006421"
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      let(:good_response) { file_fixture('../scsb_request_item_response.json') }
      it 'disallows access to request a physical ReCAP item' do
        stub_single_holding_location 'recap$pa'
        stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
        stub_catalog_raw bib_id: '9999443553506421'
        visit '/requests/9999443553506421?mfhd=22743365320006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to request a Forrestal Annex item' do
        visit '/requests/999455503506421?mfhd=22642306790006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to request a Lewis Library ReCAP item digitally' do
        stub_scsb_availability(bib_id: "9970533073506421", institution_id: "PUL", barcode: '32101051217659')
        visit '/requests/9970533073506421?mfhd=22667391160006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to request a digital copy from an item in Lewis Library' do
        visit '/requests/9970533073506421?mfhd=22667391180006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access to ask for digitizing on non circulating items' do
        visit '/requests/9995948403506421?mfhd=22500774400006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'shows an error if MFHD is not present' do
        visit '/requests/9979171923506421'
        expect(page).not_to have_content 'Please Select a location on the main record page.'
      end

      it 'disallows access to fill in form options on multi-volume works' do
        visit 'requests/99105746993506421?mfhd=22547424510006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access ReCAP Marqaund as an EDD option only' do
        stub_scsb_availability(bib_id: "99117809653506421", institution_id: "PUL", barcode: '32101106347378')
        visit '/requests/99117809653506421?mfhd=22613352460006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it "disallows access to items in the Architecture Library as available" do
        visit '/requests/99117876713506421?mfhd=22561348800006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it "disallows requests of recap pick-up only items" do
        stub_scsb_availability(bib_id: "99115783193506421", institution_id: "PUL", barcode: '32101108035435')
        visit '/requests/99115783193506421?mfhd=22534122440006421'
        expect(page).not_to have_button('Request this Item')
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'allows aeon requests for all users' do
        stub_holding_locations
        visit '/requests/9973529363506421?mfhd=22667098990006421'
        expect(page).to have_content 'Request to View in Reading Room'
        expect(page).not_to have_content 'Request this Item'
        expect(page).not_to have_selector('request--select')
      end

      it 'displays there are no available items for online only items' do
        visit '/requests/9999946923506421?mfhd=22558528920006421'
        expect(page).to have_content 'there are no requestable items for this record'
      end

      it 'disallows access on missing items' do
        stub_catalog_raw bib_id: '9917887963506421'
        visit '/requests/9917887963506421?mfhd=22503918400006421'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end

      it 'disallows access a non circulating item with not item data to be digitized' do
        visit '/requests/9941274093506421?mfhd=22690999210006421'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
        expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
      end
    end
  end

  context 'A CAS user in the affiliate user group' do
    let(:user) { FactoryBot.create(:user) }
    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: affiliate_patron_response, headers: {})
      stub_catalog_raw(bib_id: '9997371413506421')
      stub_holding_locations
      stub_availability_by_holding_id(bib_id: '9997371413506421', holding_id: '22613310220006421')
      login_as user
    end
    it 'displays the correct message when requesting a Firestone stacks item' do
      visit 'requests/9912636153506421?mfhd=22557213410006421'
      expect(page).to have_content('Request options for this item are only available to Faculty, Staff, and Students.')
    end
    it 'displays the correct message when requesting a marquand$stacks item' do
      visit 'requests/9997371413506421?mfhd=22613310220006421'
      expect(page).to have_content('Request options for this item are only available to Faculty, Staff, and Students.')
    end
  end

  context 'An Alma user that does not have a Net ID' do
    let(:alma_login_response) { file_fixture('../alma_login_response.json') }
    let(:user) { FactoryBot.create(:valid_alma_patron) }
    before do
      stub_request(:get, "#{Alma.configuration.region}/almaws/v1/users/#{user.uid}?expand=fees,requests,loans")
        .to_return(status: 200, headers: { "Content-Type" => ["application/json", "charset=UTF-8"] },
                   body: alma_login_response)
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=false")
        .to_return(status: 200, body: valid_patron_response_no_ldap, headers: {})
      login_as user
    end

    it "does not allow physical pickup request On Order PUL ReCAP Item" do
      stub_scsb_availability bib_id: '99129134216906421', institution_id: 'PUL', barcode: 'fake-barcode'
      stub_single_holding_location 'recap$pa'
      stub_catalog_raw bib_id: '99129134216906421'
      visit '/requests/99129134216906421?aeon=false&mfhd=221002424820006421'
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).not_to have_content 'Physical Item Delivery'
      expect(page).to have_content 'This item is not available'
    end

    it "allows a physical pickup request of ReCAP Item" do
      stub_single_holding_location 'recap$pa'
      stub_scsb_availability(bib_id: "9941151723506421", institution_id: "PUL", barcode: '33333059902417')
      visit 'requests/9941151723506421?mfhd=22492702000006421'
      expect(page).to have_content 'Electronic Delivery'
      expect(page).to have_content 'Physical Item Delivery'
    end

    it "allows a physical pickup request of a - Library In Use - ReCAP Item" do
      stub_scsb_availability(bib_id: "99127133356906421", institution_id: "PUL", barcode: '33333059902417')
      stub_catalog_raw bib_id: '99127133356906421'
      visit 'requests/99127133356906421?aeon=false&mfhd=22971539920006421'
      expect(page).to have_content 'Electronic Delivery'
      expect(page).to have_content 'Available for In Library Use'
    end

    it "allows only physical pickup to enumerated Forrestal Annex item" do
      stub_alma_hold_success('9947220743506421', '22734584180006421', '23734584140006421', user.uid)

      visit "requests/9947220743506421?mfhd=22734584180006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).to have_content 'Physical Item Delivery'

      expect(page).to have_content "Department of Homeland Security appropriations for 2007"
      check('requestable_selected_23734584140006421')
      select('Firestone Library', from: 'requestable__pick_up_23734584140006421')
      page.find(".submit--request") # this is really strange, but if I find the button then I can click it in the next line...
      expect do
        click_button 'Request Selected Items'
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
      expect(page).to have_content I18n.t("requests.submit.annex_success")
      email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      confirm_email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("Annex Request")
      expect(email.to).to eq(["docstor@princeton.edu"])
      expect(email.cc).to be_blank
      expect(email.html_part.body.to_s).to have_content("Department of Homeland Security appropriations for 2007")
      expect(email.html_part.body.to_s).to have_content("pt.6")
      expect(email.text_part.body.to_s).to have_content("pt.6")
      expect(confirm_email.subject).to eq(I18n.t("requests.annex.email_subject"))
      expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
      expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
      expect(confirm_email.to).to eq(["login@test.com"])
      expect(confirm_email.cc).to be_blank
      expect(confirm_email.html_part.body.to_s).to have_content("Department of Homeland Security appropriations for 2007")
      expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
    end

    it 'does not allow a ReCAP record that has no item data' do
      stub_single_holding_location 'recap$pa'
      visit "/requests/99113283293506421?mfhd=22750642660006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).not_to have_content 'Physical Item Delivery'
      expect(page).to have_content 'This item is not available'
    end

    it "does not allow access to items on campus when available" do
      visit "requests/99125428126306421?mfhd=22910398870006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).not_to have_content 'Physical Item Delivery'
      expect(page).to have_content 'Request options for this item are only available to Faculty, Staff, and Students.'
    end

    it "does not allow access to items on campus when not available" do
      visit "requests/99125452799106421?mfhd=22917143470006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).not_to have_content 'Physical Item Delivery'
      expect(page).to have_content 'This item is not available'
    end

    it "does not allow access to items on campus when enumerated" do
      visit "requests/998574693506421?mfhd=22579850750006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).not_to have_content 'Physical Item Delivery'
      expect(page).to have_content 'Request options for this item are only available to Faculty, Staff, and Students.'
    end

    it "allows access to In Process items" do
      stub_scsb_availability bib_id: '99124417723506421', institution_id: 'PUL', barcode: '32101108129568'
      stub_single_holding_location 'recap$pa'
      visit "requests/99124417723506421?mfhd=22689758840006421"
      expect(page).not_to have_content 'Electronic Delivery'
      expect(page).to have_content 'Request options for this item are only available to Faculty, Staff, and Students.'
      expect(page).not_to have_content 'This item is not available'
      # select('Firestone Library', from: 'requestable__pick_up_23922188050006421')
      expect(page).not_to have_button('Request this Item')
      # Kevin will ask circ staff to confirm
      # expect do
      #   click_button 'Request this Item'
      # end.to change { ActionMailer::Base.deliveries.count }.by(2)
      # expect(page).to have_content I18n.t("requests.submit.in_process_success")
      # email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      # confirm_email = ActionMailer::Base.deliveries.last
      # expect(email.subject).to eq("In Process Request")
      # expect(email.to).to eq(["fstcirc@princeton.edu"])
      # expect(email.cc).to be_blank
      # expect(email.html_part.body.to_s).to have_content("100 let na zashchite gosudarstva")
      # expect(confirm_email.subject).to eq("In Process Request")
      # expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
      # expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
      # expect(confirm_email.to).to eq(["login@test.com"])
      # expect(confirm_email.cc).to be_blank
      # expect(confirm_email.html_part.body.to_s).to have_content("100 let na zashchite gosudarstva")
      # expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
    end

    it "does not allow requesting of On Order books" do
      visit "requests/99125492003506421?mfhd=22927395910006421"
      expect(page).to have_content 'This item is not available'
    end
  end
  context 'when a holding has items on and off reserve' do
    let(:user) { FactoryBot.create(:user) }

    before do
      stub_single_holding_location('engineer$stacks')
      stub_single_holding_location('engineer$res')
      stub_availability_by_holding_id(bib_id: '9960102253506421', holding_id: '22548491940006421')
      stub_catalog_raw(bib_id: '9960102253506421')
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      login_as user
    end
    it 'does not display reserve items' do
      visit "requests/9960102253506421?mfhd=22548491940006421"
      expect(page.find(:css, '#enum_23939450340006421').text).to eq('Copy 4')
      expect(page).to have_content('Unavailable')
      expect(page).to have_content('In Process materials are typically available in several business days.')
      expect(page).to have_selector(:css, '#request_23939450340006421')
      expect(page).to have_none_of_selectors(:css, '#request_23939450330006421', '#request_23939450300006421', '#request_23548491930006421')
    end
  end
  context 'when a Princeton item has not made it into SCSB yet' do
    let(:user) { FactoryBot.create(:user) }
    let(:first_item) { request_scsb.items['22511126440006421'].first }

    before do
      stub_scsb_availability(bib_id: "99122304923506421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
      stub_availability_by_holding_id(bib_id: '99122304923506421', holding_id: '22511126440006421')
      stub_catalog_raw(bib_id: '99122304923506421')
      stub_single_holding_location('recap$pa')
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      login_as user
    end

    it 'is available and in process' do
      visit "requests/99122304923506421?mfhd=22511126440006421"
      expect(page.find(:css, ".request--availability").text).to eq("Available")
      expect(page).to have_content 'In Process materials are typically available in several business days'
      select('Firestone Library', from: 'requestable__pick_up_23511126430006421')
      expect do
        click_button 'Request this Item'
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
      confirm_email = ActionMailer::Base.deliveries.last
      expect(confirm_email.subject).to eq("In Process Request")
    end
  end

  context 'when the bibdata patron request fails' do
    let(:user) { FactoryBot.create(:user) }
    let(:first_item) { the_senses }

    before do
      stub_availability_by_holding_id(bib_id: '9951680203506421', holding_id: '22480938160006421')
      stub_catalog_raw(bib_id: '9951680203506421')
      stub_single_holding_location('annex$noncirc')
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 500)
      login_as user
    end

    it 'displays an error when the patron data can not be retreived' do
      visit 'requests/9951680203506421?aeon=false&mfhd=22480938160006421'

      expect(page).to have_content('A problem occurred looking up your library account.')
    end
  end
end
