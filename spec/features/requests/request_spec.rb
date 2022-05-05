# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe 'request', vcr: { cassette_name: 'request_features', record: :none }, type: :feature do
  # rubocop:disable RSpec/MultipleExpectations
  describe "request form" do
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

    let(:transaction_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction" }
    let(:transaction_note_url) { "https://lib-illiad.princeton.edu/ILLiadWebPlatform/transaction/1093806/notes" }

    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:valid_patron_no_barcode_response) { fixture('/bibdata_patron_no_barcode_response.json') }
    let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
    let(:valid_barcode_patron_pick_up_only_response) { fixture('/bibdata_patron_barcode_pick_up_only_response.json') }
    let(:valid_patron_no_campus_response) { fixture('/bibdata_patron_response_no_campus.json') }
    let(:valid_graduate_student_no_campus_response) { fixture('/bibdata_patron_response_graduate_no_campus.json') }
    let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }

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
        it "displays three authentication options" do
          stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
          visit '/requests/9999443553506421?mfhd=22743365320006421'
          expect(page).to have_content(I18n.t('blacklight.login.netid_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.barcode_login_msg'))
          expect(page).not_to have_content(I18n.t('requests.account.other_user_login_msg'))
        end
      end
    end

    context 'Temporary Shelf Locations' do
      describe 'Holding headings', js: true do
        it 'displays the temporary holding location library label' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
          fill_in 'request_email', with: 'name@email.com', wait: 2
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          expect(page).to have_content('Engineering Library')
        end

        it 'displays the temporary holding location label' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{temp_item_id}?mfhd=#{temp_id_mfhd}"
          fill_in 'request_email', with: 'name@email.com', wait: 2
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          expect(page).to have_content('Reserve')
        end
      end
    end

    context 'unauthenticated patron' do
      describe 'When visiting a request item without logging in', js: true do
        it 'allows guest patrons to identify themselves and view the form' do
          stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
          visit '/requests/9999443553506421?mfhd=22743365320006421'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'ReCAP Oversize DT549 .E274q'
        end

        it 'allows guest patrons to see aeon requests' do
          visit '/requests/993365253506421?mfhd=22220245570006421'
          pending "Guest have no access during COVID-19 pandemic"
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button(I18n.t('requests.account.other_user_login_btn'))
          wait_for_ajax
          expect(page).to have_content 'Request to View in Reading Room'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guest patrons to request a physical recap item' do
          pending "Guest have no access during COVID-19 pandemic"
          stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
          visit '/requests/9999443553506421?mfhd=22743365320006421'
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_no_content 'Electronic Delivery'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request this Item'
          # wait_for_ajax
          expect(page).to have_content 'Request submitted'
        end

        it 'prohibits guest patrons from requesting In-Process items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{in_process_id}"
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'Item is not requestable.'
        end

        it 'prohibits guest patrons from requesting On-Order items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit "/requests/#{on_order_id}"
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).not_to have_selector('.btn--primary')
        end

        it 'allows guest patrons to access Online items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9994692?mfhd=9800910'
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'www.jstor.org'
        end

        it 'allows guest patrons to request Aeon items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9921676693506421'
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_link('Request to View in Reading Room')
        end

        it 'prohibits guest patrons from using Borrow Direct, ILL, and Recall on Missing items' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_content 'Item is not requestable.'
        end

        # TODO: Activate test when campus has re-opened
        it 'allows guests to request from Annex, but not from Firestone in mixed holding' do
          pending "Guest have no access during COVID-19 pandemic"
          visit '/requests/9922868943506421'
          click_link(I18n.t('requests.account.other_user_login_msg'), wait: 2)
          fill_in 'request_email', with: 'name@email.com'
          fill_in 'request_user_name', with: 'foobar'
          click_button I18n.t('requests.account.other_user_login_btn')
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_selected_7484608', disabled: true
          expect(page).to have_field 'requestable_user_supplied_enum_2576882'
          check('requestable__selected', exact: true)
          fill_in 'requestable_user_supplied_enum_2576882', with: 'test'
          select('Firestone Library', from: 'requestable__pick_up_2576882')
          click_button 'Request Selected Items'
          expect(page).to have_content I18n.t('requests.submit.annex_success')
        end
      end
    end

    context 'a princeton net ID user' do
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
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_response, headers: {})
        login_as user
      end

      describe 'When visiting an alma ID as a CAS User' do
        it 'Shows a ReCAP item that is at preservation and conservation as a partner request' do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Zhongguo xin li xue hui", "LoanTitle" => "Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science", "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "BF8.C5 H76", "CitedIn" => "https://catalog.princeton.edu/catalog/9941150973506421", "ItemInfo3" => "no.217-218", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Loan Request"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_scsb_availability(bib_id: "9941150973506421", institution_id: "PUL", barcode: '32101099680850', item_availability_status: 'Not Available')
          visit 'requests/9941150973506421?mfhd=22492663380006421&source=pulsearch'
          expect(page).to have_content 'Not Available'
          check "requestable_selected_23492663220006421"
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it 'allow CAS patrons to request an available ReCAP item.' do
          stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "9994933183506421", callNumber: "PJ7962.A5495 A95 2016", chapterTitle: "", deliveryLocation: "PA", emailAddress: 'a@b.com', endPage: "", issue: "", itemBarcodes: ["32101095798938"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999",
                                       requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "ʻAwāṭif madfūnah عواطف مدفونة", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, Requests::Config[:scsb_base])
            .with(headers: { 'Accept' => '*/*' })
            .to_return(status: 200, body: "<document count='1' sent='true'></document>", headers: {})
          stub_request(:post, "#{Alma.configuration.region}/almaws/v1/bibs/9994933183506421/holdings/22558528920006421/items/23558528910006421/requests?user_id=960594184")
            .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
            .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
          visit "/requests/#{mms_id}"
          expect(page).to have_content 'Electronic Delivery'
          # some weird issue with this and capybara examining the page source shows it is there.
          expect(page).to have_selector '#request_user_barcode', visible: false
          choose('requestable__delivery_mode_23558528910006421_print') # chooses 'print' radio button
          select('Firestone Library', from: 'requestable__pick_up_23558528910006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
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

        # it 'allow CAS patrons to request an available ReCAP item with Help Me' do
        #   visit "/requests/#{mms_id}"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        it 'allows CAS patrons to request In-Process items and can only be delivered to their holding library' do
          visit "/requests/#{in_process_id}"
          expect(page).to have_content 'In Process'
          expect(page).to have_content 'Pick-up location: East Asian Library'
          expect(page).to have_button('Request this Item', disabled: false)
          click_button 'Request this Item'
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
        end

        it 'makes sure In-Process ReCAP items with no holding library can be delivered anywhere' do
          visit "/requests/#{recap_in_process_id}"
          expect(page).to have_content 'In Process'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up_23753408600006421')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up_23753408600006421')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up_23753408600006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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

        # it 'makes sure In-Process ReCAP items get Help Me' do
        #   visit "/requests/#{recap_in_process_id}"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        it 'allows CAS patrons to request On-Order items' do
          visit "/requests/#{on_order_id}"
          expect(page).to have_button('Request Selected Items', disabled: false)
          check 'requestable_selected_23480270130006421'
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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

        it 'allows CAS patrons to request a ReCAP record that has no item data' do
          visit "/requests/99113283293506421?mfhd=22750642660006421"
          check('requestable__selected', exact: true)
          fill_in 'requestable[][user_supplied_enum]', with: 'Some Volume'
          expect(page).to have_button('Request this Item', disabled: false)
        end

        it 'allows CAS patrons to locate an ReCAP record that has no item data' do
          visit "/requests/#{on_shelf_no_items_id}"
          choose('requestable__delivery_mode_22740191170006421_print') # chooses 'print' radio button
          expect(page).to have_content "Pick-up location: Firestone Library"
          expect(page).to have_content "Requests for pick-up typically take 2 business days to process."
        end

        it 'allows CAS patrons to locate an on_shelf record' do
          stub_alma_hold_success('9912636153506421', '22557213410006421', '23557213400006421', '960594184')

          visit "requests/9912636153506421?mfhd=22557213410006421"
          expect(page).to have_content 'Pick-up location: Firestone Library'
          choose('requestable__delivery_mode_23557213400006421_print') # chooses 'print' radio button
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (FIRESTONE$STACKS) PR3187 .L443 1951")
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

        it 'allows CAS patrons to request an item twice and see a message about the duplication' do
          stub_alma_hold('9912636153506421', '22557213410006421', '23557213400006421', '960594184', status: 200, fixture_name: "alma_hold_error_response.json")

          visit "requests/9912636153506421?mfhd=22557213410006421"
          expect(page).to have_content 'Pick-up location: Firestone Library'
          choose('requestable__delivery_mode_23557213400006421_print') # chooses 'print' radio button
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'Electronic Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(page).to have_content 'You have sent a duplicate request to Alma for this item'
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        it 'allows patrons to request a physical recap item' do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
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
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
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

        # it 'allows patrons to request a physical recap item get Help Me' do
        #   visit "/requests/9944355?mfhd=9757511"
        #   expect(page).to have_content "Requests for ReCAP materials will be unavailable during a planned system update"
        #   expect(page).to have_content 'Help Me Get It'
        # end

        it 'allows patrons to request a Forrestal annex' do
          alma_url = stub_alma_hold_success('999455503506421', '22642306790006421', '23642306760006421', '960594184')
          visit '/requests/999455503506421?mfhd=22642306790006421'
          choose('requestable__delivery_mode_23642306760006421_print') # chooses 'print' radio button
          # todo: should we still have the text?
          # expect(page).to have_content 'Item offsite at Forrestal Annex. Requests for pick-up'
          expect(page).to have_content 'Electronic Delivery'
          select('Firestone Library, Resource Sharing (Staff Only)', from: 'requestable__pick_up_23642306760006421')
          select('Technical Services 693 (Staff Only)', from: 'requestable__pick_up_23642306760006421')
          select('Technical Services HMT (Staff Only)', from: 'requestable__pick_up_23642306760006421')
          select('Firestone Library', from: 'requestable__pick_up_23642306760006421')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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
          expect(a_request(:post, alma_url)).to have_been_made
        end

        it 'allows patrons to request electronic delivery of a Forrestal item' do
          stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/9956562643506421/raw")
            .to_return(status: 200, body: fixture('/9956562643506421.json'), headers: {})
          stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/9956562643506421/holdings/22700125400006421/availability.json")
            .to_return(status: 200, body: fixture('/availability_9956562643506421.json'), headers: {})
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9956562643506421?mfhd=22700125400006421'
          choose('requestable__delivery_mode_23700125390006421_edd') # chooses 'electronic delivery' radio button
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
        end

        it 'allows patrons to request a Lewis recap item digitally' do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_scsb_availability(bib_id: "9970533073506421", institution_id: "PUL", barcode: '32101051217659')
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/9970533073506421?mfhd=22667391160006421'
          choose('requestable__delivery_mode_23667391150006421_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Pick-up location: Lewis Library'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
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

        it 'allows patrons to request a Lewis' do
          stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
          stub_alma_hold_success('9970533073506421', '22667391180006421', '23667391170006421', '960594184')
          visit '/requests/9970533073506421?mfhd=22667391180006421'
          choose 'requestable__delivery_mode_23667391170006421_print'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          check 'requestable_selected_23667391170006421'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content 'Item has been requested for pick-up'
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (LEWIS$STACKS) QA646 .A44 2012")
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

        it 'allows patrons to request a on-order' do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          ## having trouble finding a firestone item in BL.
          visit '/requests/99103251433506421?mfhd=22480270140006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
          check 'requestable_selected_23480270130006421'
          click_button 'Request Selected Items'
          expect(a_request(:post, scsb_url)).not_to have_been_made
          expect(page).to have_content 'Request submitted'
        end

        it 'allows patrons to ask for digitizing on non circulating items' do
          visit '/requests/9995948403506421?mfhd=22500774400006421'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Pick-up location: Lewis Library'
          expect(page).to have_css '.submit--request'
        end

        it 'allows patrons to request a PPL Item' do
          pending "PPL library closed"
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/995788303506421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          # temporary change issue 438
          # select('Firestone Library', from: 'requestable__pick_up')
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
        end

        it 'allows filtering items by mfhd' do
          visit '/requests/9979171923506421?mfhd=22637778670006421'
          expect(page).to have_content 'Pick-up location: Lewis Library'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a print copy' do
          visit 'requests/99105746993506421?mfhd=22547424510006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          expect(page).to have_content 't. 2, no 2 (2018 )' # include enumeration and chron
          expect(page).to have_content 't. 3, no 2 (2019 )' # include enumeration and chron
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_22547424510006421", with: "ABC ZZZ"
          choose('requestable__delivery_mode_22547424510006421_print') # choose the print radio button
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Paging Request for Firestone Library")
          expect(email.to).to eq(["fstpage@princeton.edu"])
          expect(email.cc).to be_nil
          expect(email.html_part.body.to_s).to have_content("ABC ZZZ")
          expect(confirm_email.subject).to eq("Paging Request for Firestone Library")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_nil
          expect(confirm_email.html_part.body.to_s).to have_content("ABC ZZZ")
        end

        it 'show a fill in form if the item is an enumeration (Journal ect.) and choose a electronic copy' do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Mefisto : rivista di medicina, filosofia, storia", "PhotoItemPublisher" => "", "ISSN" => "", "CallNumber" => "R131.A1 M38", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/99105746993506421", "PhotoJournalYear" => "2017", "PhotoJournalVolume" => "ABC ZZZ",
                                       "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "1028553183", "DocumentType" => "Article", "Location" => "Firestone Library - Stacks", "PhotoArticleTitle" => "ELECTRONIC CHAPTER"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit 'requests/99105746993506421?mfhd=22547424510006421'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          expect(page).to have_content 'If the specific volume does not appear in the list below, please enter it here:'
          within(".user-supplied-input") do
            check('requestable__selected')
          end
          fill_in "requestable_user_supplied_enum_22547424510006421", with: "ABC ZZZ"
          choose('requestable__delivery_mode_22547424510006421_edd') # choose the print radio button
          within("#fields-eed__22547424510006421") do
            fill_in "Article/Chapter Title", with: "ELECTRONIC CHAPTER"
          end
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(1)
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

        it 'Shows Marqaund Recap Item as an EDD option or In Library Use, no delivery' do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url).to_return(status: 200, body: good_response, headers: {})
          stub_scsb_availability(bib_id: "99117809653506421", institution_id: "PUL", barcode: '32101106347378')
          visit '/requests/99117809653506421?mfhd=22613352460006421'
          choose('requestable__delivery_mode_23613352450006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.recap_edd.brief_msg')
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Article/Chapter Title (Required)'
          fill_in "Title", with: "my stuff"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(email.html_part.body.to_s).to have_content("You will receive an email including a link where you can download your scanned section")
        end

        it "shows items in the Architecture Library as available" do
          stub_alma_hold_success('99117876713506421', '22561348800006421', '23561348790006421', '960594184')
          visit '/requests/99117876713506421?mfhd=22561348800006421'
          # choose('requestable__delivery_mode_8298341_edd') # chooses 'edd' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Pick-up location: Architecture Library'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (ARCH$STACKS) NA1585.A23 S7 2020")
          expect(email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
          expect(confirm_email.subject).to eq("Architecture Library Pick-up Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Abdelhalim Ibrahim Abdelhalim : an architecture of collective memory")
        end

        it "allows requests of recap pick-up only items" do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_scsb_availability(bib_id: "99115783193506421", institution_id: "PUL", barcode: '32101108035435')
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: nil, bibId: "99115783193506421", callNumber: "DVD", chapterTitle: nil, deliveryLocation: "PA", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["32101108035435"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "Chernobyl : a 5-part miniseries", username: "jstudent", volume: nil))
            .to_return(status: 200, body: good_response, headers: {})
          stub_request(:post, "#{Alma.configuration.region}/almaws/v1/bibs/99115783193506421/holdings/22534122440006421/items/23534122430006421/requests?user_id=960594184")
            .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
            .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
          visit '/requests/99115783193506421?mfhd=22534122440006421'
          expect(page).not_to have_content 'Item is not requestable.'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).to have_content 'Item off-site at ReCAP facility. Request for delivery in 1-2 business days.'
          select('Firestone Library', from: 'requestable__pick_up_23534122430006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received")
          expect(confirm_email.html_part.body.to_s).to have_content("Chernobyl : a 5-part miniseries")
        end

        it 'doe snot error for Online items' do
          visit '/requests/9999946923506421?mfhd=9800910'
          expect(page).to have_content 'there are no requestable items for this record'
        end

        it 'Borrow Direct successful on Missing items' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_return('123456')
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check('requestable_selected_23503918390006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(page).to have_content 'Request submitted to BorrowDirect'
          expect(page).to have_content 'Your request number is 123456'
          expect(page).not_to have_content 'Your request was submittied. Our library staff will review the request and contact you with aviable options.'
        end

        it 'Borrow direct unsuccessful, but no exception thrown sent on to illiad' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_return(nil)
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check('requestable_selected_23503918390006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
        end

        it 'Borrow Direct unsuccessful on missing item sent to illiad' do
          borrow_direct = ::BorrowDirect::RequestItem.new("22101008199999")
          expect(::BorrowDirect::RequestItem).to receive(:new).with("22101008199999").and_return(borrow_direct)
          expect(borrow_direct).to receive(:make_request).with("Firestone Library", isbn: '9780812929645').and_raise(::BorrowDirect::Error, "Error with borrow direct")
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing",
                                       "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Trump, Donald Bohner, Kate", "LoanTitle" => "Trump : the art of the comeback",
                                       "LoanPublisher" => nil, "ISSN" => "9780812929645", "CallNumber" => "HC102.5.T78 A3 1997", "CitedIn" => "https://catalog.princeton.edu/catalog/9917887963506421", "ItemInfo3" => "",
                                       "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check('requestable_selected_23503918390006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Trump : the art of the comeback")
        end

        it 'allow interlibrary loan to be requested' do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "U.S. census office", "LoanTitle" => "7th census of U.S.1850",
                                       "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "HA202.1850.A5q Oversize", "CitedIn" => "https://catalog.princeton.edu/catalog/9915057783506421", "ItemInfo3" => "", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9915057783506421?mfhd=22686942210006421'
          expect(page).to have_content 'Request via Partner Library'
          expect(page).to have_content 'Pick-up location: Firestone Library'
          check('requestable_selected_23686942200006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          expect(page).to have_content 'Your request was submitted. Our library staff will review the request and contact you with any questions or updates.'
          expect(page).not_to have_content 'Request submitted to BorrowDirect'
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Partner Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Requests typically are filled within two weeks when possible")
          expect(confirm_email.html_part.body.to_s).to have_content("7th census of U.S.1850")
        end

        it 'an annex item with user supplied information creates annex emails' do
          visit '/requests/9922868943506421?mfhd=22692156940006421'
          expect(page).to have_field 'requestable__selected', disabled: false
          expect(page).to have_field 'requestable_user_supplied_enum_22692156940006421'
          within('#request_user_supplied_22692156940006421') do
            check('requestable__selected', exact: true)
            fill_in 'requestable_user_supplied_enum_22692156940006421', with: 'test'
          end
          select('Firestone Library', from: 'requestable__pick_up_22692156940006421')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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

        it 'allows a non circulating item with no item data to be digitized' do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoArticleAuthor" => "I Aman Author", "PhotoItemAuthor" => "Herzog, Hans-Michael Daros Collection (Art)", "PhotoJournalTitle" => "La mirada : looking at photography in Latin America today", "PhotoItemPublisher" => "Zürich: Edition Oehrli", "PhotoJournalIssue" => "",
                                       "Location" => "Marquand Library - Stacks", "ISSN" => "9783905597363", "CallNumber" => "", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9941274093506421", "PhotoJournalVolume" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand EDD", "AcceptNonEnglish" => true, "ESPNumber" => "", "DocumentType" => "Book", "PhotoArticleTitle" => "ABC", "PhotoJournalYear" => "2002"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_clancy_status(barcode: "32101072349515")
          visit '/requests/9941274093506421?mfhd=22690999210006421'
          choose('requestable__delivery_mode_22690999210006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.marquand_edd.brief_msg')
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Not Available'
          expect(page).not_to have_content 'Available for In Library Use'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
          expect(confirm_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("La mirada : looking at photography in Latin America today")
          expect(marquand_email.html_part.body.to_s).to have_content("ABC")
          expect(marquand_email.html_part.body.to_s).to have_content("I Aman Author")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it 'allows an in process item to be requested' do
          visit "/requests/#{in_process_id}"
          expect(page).to have_content 'In Process materials are typically available in several business days'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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

        context 'disavowed user' do
          it 'allows a non circulating item with not item data to be digitized to be requested, but then errors' do
            stub_illiad_patron(disavowed: true)
            stub_clancy_status(barcode: "32101072349515")
            visit '/requests/9941274093506421?mfhd=22690999210006421'
            expect(page).to have_content 'Electronic Delivery'
            choose('requestable__delivery_mode_22690999210006421_edd') # chooses 'edd' radio button
            fill_in "Article/Chapter Title", with: "ABC"
            fill_in "Author", with: "I Aman Author"
            expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
            expect(page).to have_content "You no longer have an active account and may not make digitization requests."
            error_email = ActionMailer::Base.deliveries.last
            expect(error_email.subject).to eq("Request Service Error")
            expect(error_email.to).to eq(["docdel@princeton.edu"])
          end
        end

        # it 'allows an etas item to be digitized' do
        #   # TODO: - Do we need to worry about ETAS? No, PUL ETAS is being deprecated at alma go live
        #   stub_illiad_patron
        #   stub_request(:post, transaction_url)
        #     .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Edwards, Ruth Dudley", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "James Connolly", "PhotoItemPublisher" => "Dublin: Gill and Macmillan", "ISSN" => "9780717111121 9780717111114", "CallNumber" => "DA965.C7 E36 1981", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/991626323506421", "PhotoJournalYear" => "1981", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => "8391816", "DocumentType" => "Book", "Location" => "Online - HathiTrust Emergency Temporary Access", "PhotoArticleTitle" => "ABC"))
        #     .to_return(status: 200, body: responses[:transaction_created], headers: {})
        #   stub_request(:post, transaction_note_url)
        #     .to_return(status: 200, body: responses[:note_created], headers: {})
        #   visit '/requests/991626323506421?mfhd=2239424020006421'
        #   expect(page).to have_content 'Electronic Delivery'
        #   expect(page).to have_content 'Online- HathiTrust Emergency Temporary Access DA965.C7 E36 1981'
        #   expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
        #   expect(page).not_to have_content('make an appointment')
        #   fill_in "Article/Chapter Title", with: "ABC"
        #   expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
        #   expect(page).to have_content 'Request submitted'
        #   confirm_email = ActionMailer::Base.deliveries.last
        #   expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.to).to eq(["a@b.com"])
        #   expect(confirm_email.cc).to be_blank
        #   expect(confirm_email.html_part.body.to_s).to have_content("James Connolly")
        # end

        # it "allows an Recap etas item to be digitized" do
        #   # TODO: - Do we need to worry about ETAS?
        #   scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
        #   stub_request(:post, scsb_url)
        #     .with(body: hash_including(author: "", bibId: "7599", callNumber: "PJ3002 .S4", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101073604215"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Semitistik", username: "jstudent", volume: ""))
        #     .to_return(status: 200, body: good_response, headers: {})
        #   visit '/requests/9975993506421?mfhd=22153200840006421'
        #   expect(page).to have_content 'Electronic Delivery'
        #   expect(page).to have_content 'ReCAP- HathiTrust Emergency Temporary Access ReCAP PJ3002 .S4'
        #   expect(page).to have_content I18n.t("requests.recap_edd.note_msg")
        #   expect(page).not_to have_content 'If the specific volume does not appear in the list below, please enter it here:'
        #   fill_in "Article/Chapter Title", with: "ABC"
        #   expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
        #   expect(a_request(:post, scsb_url)).to have_been_made
        #   confirm_email = ActionMailer::Base.deliveries.last
        #   expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        #   expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
        #   expect(confirm_email.html_part.body.to_s).to have_content("Semitistik")
        #   expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        # end

        # need to check on CUL etas
        it "allows a columbia item that is not in hathi etas to be picked up or digitized" do
          stub_scsb_availability(bib_id: "1000060", institution_id: "CUL", barcode: 'CU01805363')
          stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=21154437")
            .to_return(status: 200, body: '[]')
          stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2879197/raw")
            .to_return(status: 200, body: fixture('/SCSB-2879197.json'), headers: {})
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-2879197", callNumber: "PG3479.3.I84 Z778 1987g", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU01805363"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879197'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497908_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP PG3479.3.I84 Z778 1987g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Mir, uvidennyĭ s gor : ocherk tvorchestva Shukurbeka Beĭshenalieva")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "allows a columbia item that is open access to be picked up or digitized" do
          stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=502557695")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"502557695","bibid":"9938633913506421","status":"ALLOW","origin":"CUL"}]')
          stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-4634001/raw")
            .to_return(status: 200, body: fixture('/SCSB-4634001.json'), headers: {})
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-4634001", callNumber: "4596 2907.88 1901", chapterTitle: "", deliveryLocation: "QX", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU51481294"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Chong wen men shang shui ya men xian xing shui ze. 崇文門 商稅 衙門 現行 稅則.", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-4634001'
          expect(page).to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_6826565_print') # chooses 'print' radio button
          expect(page).to have_content('Pick-up location: Firestone Circulation Desk')
          expect(page).to have_content 'ReCAP 4596 2907.88 1901'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(" Your request to pick this item up has been received. We will process the requests as soon as possible")
          expect(confirm_email.html_part.body.to_s).to have_content("Chong wen men shang shui ya men xian xing shui ze")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "allows a columbia item that is ETAS to only be digitized" do
          stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=19774500")
            .to_return(status: 200, body: '[{"id":null,"oclc_number":"19774500","bibid":"99310000663506421","status":"DENY","origin":"CUL"}]')
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2879206/raw")
            .to_return(status: 200, body: fixture('/SCSB-2879206.json'), headers: {})
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-2879206", callNumber: "ML3477 .G74 1989g", chapterTitle: "ABC", deliveryLocation: "", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["CU61436348"], itemOwningInstitution: "CUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "EDD", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Let's face the music : the golden age of popular song", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-2879206'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_4497920_edd') # chooses 'edd' radio button
          fill_in "Article/Chapter Title", with: "ABC"
          expect(page).to have_content 'ReCAP ML3477 .G74 1989g'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 1-2 business days to process")
          expect(confirm_email.html_part.body.to_s).to have_content("Let's face the music : the golden age of popular song")
          expect(confirm_email.html_part.body.to_s).to have_content("ABC")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "places a hold and sends emails for a marquand in library use item" do
          stub_alma_hold_success('9956364873506421', '22587331490006421', '23587331480006421', '960594184')
          stub_clancy_status(barcode: "32101072349515")
          visit '/requests/9956364873506421?mfhd=22587331490006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).not_to have_link('make an appointment', href: "https://libcal.princeton.edu/seats?lid=10656")
          choose('requestable__delivery_mode_23587331480006421_in_library') # chooses 'in library' radio button
          expect(page).to have_content('Marquand Library at Firestone')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("You will be notified via email when your item is available.")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Pick-up By")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request In Library")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "places a hold and a clancy request for a marquand in library use item at Clancy" do
          stub_alma_hold_success('9956364873506421', '22587331490006421', '23587331480006421', '960594184')
          stub_clancy_status(barcode: "32101072349515", status: "Item In at Rest")
          stub_clancy_post(barcode: "32101072349515")
          visit '/requests/9956364873506421?mfhd=22587331490006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          choose('requestable__delivery_mode_23587331480006421_in_library') # chooses 'in_library' radio button
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy In Library")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "only has edd for a marquand in library use item at Clancy that is unavailable" do
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Cambridge, Mass: Harvard University P...", "ISSN" => "9780674030930", "CallNumber" => "N7668.D6 J64 2008", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9956364873506421",
                                       "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy UNAVAIL EDD", "AcceptNonEnglish" => true, "ESPNumber" => "213495319", "DocumentType" => "Book", "Location" => "Marquand Library - Stacks", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Digitization Request Marquand Item at Clancy (Unavailable)"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          stub_clancy_status(barcode: "32101072349515", status: "Item In Accession Process")
          visit '/requests/9956364873506421?mfhd=22587331490006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).not_to have_content 'Available for In Library Use'
          expect(page).to have_content 'Electronic Delivery'
          choose('requestable__delivery_mode_23587331480006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.clancy_unavailable_edd.brief_msg')
          expect(page).to have_content I18n.t("requests.clancy_unavailable_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect(page).not_to have_content("translation missing")
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t("requests.clancy_unavailable_edd.email_conf_msg"))
          expect(confirm_email.html_part.body.to_s).to have_content("ABC")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan - Unavailable at Clancy")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.html_part.body.to_s).to have_content("ABC")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "sends an email and places an illiad request for a marquand edd item at Clancy" do
          stub_alma_hold_success('9956364873506421', '22587331490006421', '23587331480006421', '960594184')
          stub_clancy_status(barcode: "32101072349515", status: "Item In at Rest")
          stub_clancy_post(barcode: "32101072349515")
          stub_illiad_patron
          stub_request(:post, transaction_url)
            .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Article Express Processing", "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"), "WantedBy" => "Yes, until the semester's", "PhotoItemAuthor" => "Johns, Catherine", "PhotoArticleAuthor" => "", "PhotoJournalTitle" => "Dogs : history, myth, art", "PhotoItemPublisher" => "Cambridge, Mass: Harvard University P...", "ISSN" => "9780674030930", "CallNumber" => "N7668.D6 J64 2008", "PhotoJournalInclusivePages" => "-", "CitedIn" => "https://catalog.princeton.edu/catalog/9956364873506421",
                                       "PhotoJournalYear" => "2008", "PhotoJournalVolume" => "", "PhotoJournalIssue" => "", "ItemInfo3" => "", "ItemInfo4" => "", "CitedPages" => "Marquand Clancy EDD", "AcceptNonEnglish" => true, "ESPNumber" => "213495319", "DocumentType" => "Book", "Location" => "Marquand Library - Stacks", "PhotoArticleTitle" => "ABC"))
            .to_return(status: 200, body: responses[:transaction_created], headers: {})
          stub_request(:post, transaction_note_url)
            .with(body: hash_including("Note" => "Digitization Request Marquand Item at Clancy"))
            .to_return(status: 200, body: responses[:note_created], headers: {})
          visit '/requests/9956364873506421?mfhd=22587331490006421'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          choose('requestable__delivery_mode_23587331480006421_edd') # chooses 'edd' radio button
          expect(page).to have_content I18n.t('requests.clancy_edd.brief_msg')
          expect(page).to have_content I18n.t("requests.clancy_edd.note_msg")
          fill_in "Article/Chapter Title", with: "ABC"
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(a_request(:post, transaction_url)).to have_been_made
          expect(a_request(:post, transaction_note_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 4-8 business days")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("Dogs : history, myth, art")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end

        it "shows in library use option for SCSB ReCAP items in Firestone" do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: nil, bibId: "SCSB-8953469", callNumber: "ReCAP 18-69309", chapterTitle: nil, deliveryLocation: "QX", emailAddress: "a@b.com", endPage: nil, issue: nil, itemBarcodes: ["33433121206696"], itemOwningInstitution: "NYPL", patronBarcode: "22101008199999", requestNotes: nil, requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: nil, titleIdentifier: "1955-1968 : gli artisti italiani alle Documenta di Kassel", username: "jstudent", volume: nil))
            .to_return(status: 200, body: good_response, headers: {})
          stub_scsb_availability(bib_id: ".b215204128", institution_id: "NYPL", barcode: '33433121206696')
          stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-8953469/raw")
            .to_return(status: 200, body: fixture('/SCSB-8953469.json'), headers: {})
          visit 'requests/SCSB-8953469'
          expect(page).not_to have_content 'Help Me Get It'
          expect(page).to have_content 'Available for In Library'
          expect(page).not_to have_content 'Electronic Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(page).to have_content "Request submitted. See confirmation email with details about when your item(s) will be available"
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("955-1968 : gli artisti italiani alle Documenta di Kassel")
        end

        it 'Shows marqaund recap item as an EDD or In Library Use' do
          stub_scsb_availability(bib_id: "99117809653506421", institution_id: "PUL", barcode: '32101106347378')
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "99117809653506421", callNumber: "N6923.B257 H84 2020", chapterTitle: "", deliveryLocation: "PJ", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32101106347378"], itemOwningInstitution: "PUL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Alesso Baldovinetti und die Florentiner Malerei der Frührenaissance", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/99117809653506421?mfhd=22613352460006421'
          stub_request(:post, "#{Alma.configuration.region}/almaws/v1/bibs/99117809653506421/holdings/22613352460006421/items/23613352450006421/requests?user_id=960594184")
            .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "marquand"))
            .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
          choose('requestable__delivery_mode_23613352450006421_in_library') # chooses 'in_library' radio button
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library'
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          expect(page).not_to have_content 'Physical Item Delivery'
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(a_request(:post, scsb_url)).to have_been_made
          expect(a_request(:post, scsb_url)).to have_been_made
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("2-4 business days")
          expect(confirm_email.html_part.body.to_s).to have_content("Alesso Baldovinetti und die Florentiner Malerei der Frührenaissance")
        end

        it 'Shows recap item that has not made it to recap yet as in process' do
          visit '/requests/99123340993506421?mfhd=22569931350006421'
          expect(page).to have_content 'In Process'
          select('Firestone Library', from: 'requestable__pick_up_23896622240006421')
          expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t("requests.submit.in_process_success")
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("In Process Request")
          expect(email.to).to eq(["fstcirc@princeton.edu"])
          expect(email.cc).to be_blank
          expect(email.html_part.body.to_s).to have_content("Ḍaḥāyā al-zawāj")
          expect(confirm_email.subject).to eq("In Process Request")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.to).to eq(["a@b.com"])
          expect(confirm_email.cc).to be_blank
          expect(confirm_email.html_part.body.to_s).to have_content("Ḍaḥāyā al-zawāj")
          expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "Delivers scsb in library use art items only to marquand" do
          stub_scsb_availability(bib_id: "9008865", institution_id: "CUL", barcode: 'AR01220551')
          visit '/requests/SCSB-5595350'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content 'Pick-up location: Marquand Library at Firestone'
        end

        it "Delivers scsb in library use music items only to mendel" do
          stub_scsb_availability(bib_id: "14577462", institution_id: "CUL", barcode: 'MR00393223')
          visit '/requests/SCSB-9726156'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content 'Pick-up location: Mendel Music Library'
        end

        it "allows a harvard item that is in library use for Marquand to be viewwed" do
          scsb_url = "#{Requests::Config[:scsb_base]}/requestItem/requestItem"
          stub_scsb_availability(bib_id: "990143653400203941", institution_id: "HL", barcode: '32044136602687')
          stub_request(:post, scsb_url)
            .with(body: hash_including(author: "", bibId: "SCSB-9919951", callNumber: "N5230.M62 R39 2014", chapterTitle: "", deliveryLocation: "PJ", emailAddress: "a@b.com", endPage: "", issue: "", itemBarcodes: ["32044136602687"], itemOwningInstitution: "HL", patronBarcode: "22101008199999", requestNotes: "", requestType: "RETRIEVAL", requestingInstitution: "PUL", startPage: "", titleIdentifier: "Razón de ser : obras emblemáticas de la Colección Carrillo Gil : Orozco, Rivera, Siqueiros, Paalen, Gerzso", username: "jstudent", volume: ""))
            .to_return(status: 200, body: good_response, headers: {})
          visit '/requests/SCSB-9919951'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).to have_content 'Available for In Library Use'
          expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
          expect(page).to have_content 'ReCAP N5230.M62 R39 2014'
          # expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
          # expect(a_request(:post, scsb_url)).to have_been_made
          # expect(page).to have_content "Request submitted to ReCAP, our offsite storage facility"
          # confirm_email = ActionMailer::Base.deliveries.last
          # expect(confirm_email.subject).to eq("Patron Initiated Catalog Request Confirmation")
          # expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          # expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          # expect(confirm_email.html_part.body.to_s).to have_content(" Your request to pick this item up has been received. We will process the requests as soon as possible")
          # expect(confirm_email.html_part.body.to_s).to have_content("Chong wen men shang shui ya men xian xing shui ze")
          # expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
        end

        it "shows a on order princeton ReCap item as Acquisition" do
          stub_scsb_availability(bib_id: "99125378834306421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
          visit '/requests/99125378834306421?mfhd=22897184810006421'
          expect(page).to have_content 'On Order books have not yet been received. Place a request to be notified when this item has arrived and is ready for your pick-up.'
        end

        it 'Request an enumerated book correctly' do
          stub_alma_hold_success('9973397793506421', '22541187250006421', '23541187200006421', '960594184')
          visit '/requests/9973397793506421?mfhd=22541187250006421'
          expect(page).to have_content "Han'guk hyŏndaesa sanch'aek. No Mu-hyŏn sidae ŭi myŏngam"
          check('requestable_selected_23541187200006421')
          choose('requestable__delivery_mode_23541187200006421_print')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(page).to have_content I18n.t("requests.submit.on_shelf_success")
          email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          confirm_email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq("On the Shelf Paging Request (EASTASIAN$CJK) DS923.25 .K363 2011")
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

        it 'Request an annex in library book correctly' do
          stub_alma_hold_success('9941347943506421', '22560381400006421', '23560381360006421', '960594184')
          visit 'requests/9941347943506421?mfhd=22560381400006421'
          expect(page).to have_content "Er ru ting Qun fang pu : [san shi juan]"
          check('requestable_selected_23560381360006421')
          choose('requestable__delivery_mode_23560381360006421_in_library')
          expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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
            stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/99105816503506421/raw")
              .to_return(status: 200, body: fixture('/catalog_99105816503506421.json'), headers: {})
            stub_request(:post, transaction_url)
              .with(body: hash_including("Username" => "jstudent", "TransactionStatus" => "Awaiting Request Processing", "RequestType" => "Loan", "ProcessType" => "Borrowing", "WantedBy" => "Yes, until the semester's", "LoanAuthor" => "Zhongguo xin li xue hui", "LoanTitle" => "Xin li ke xue = Journal of psychological science 心理科学 = Journal of psychological science", "LoanPublisher" => nil, "ISSN" => "", "CallNumber" => "BF8.C5 H76", "CitedIn" => "https://catalog.princeton.edu/catalog/9941150973506421", "ItemInfo3" => "no.217-218", "ItemInfo4" => nil, "CitedPages" => "COVID-19 Campus Closure", "AcceptNonEnglish" => true, "ESPNumber" => nil, "DocumentType" => "Book", "LoanPlace" => nil))
              .to_return(status: 200, body: responses[:transaction_created], headers: {})
          end
          it 'with an electronic delivery' do
            visit 'requests/99105816503506421?mfhd=22514405160006421'
            expect(page).to have_content "SOS brutalism : a global survey"
            expect(page).to have_content 'Elser, Oliver'
            expect(page).to have_content 'Physical Item Delivery'
            expect(page).to have_content 'Electronic Delivery'
            expect(page).to have_content "Architecture Library- Librarian's Office NA682.B7 S673 2017b"
            expect(page).to have_content 'Available - Item in place'
            expect(page).to have_content 'vol.1'
            check('requestable_selected_23514405150006421')
            choose('requestable__delivery_mode_23514405150006421_edd')
            fill_in 'requestable__edd_art_title_23514405150006421', with: 'some text'
            expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(1)
            expect(a_request(:post, transaction_url)).to have_been_made
          end
          it 'with a Physical delivery' do
            visit 'requests/99105816503506421?mfhd=22514405160006421'
            expect(page).to have_content "SOS brutalism : a global survey"
            expect(page).to have_content 'Elser, Oliver'
            expect(page).to have_content 'Physical Item Delivery'
            expect(page).to have_content 'Electronic Delivery'
            expect(page).to have_content "Architecture Library- Librarian's Office NA682.B7 S673 2017b"
            expect(page).to have_content 'Available - Item in place'
            expect(page).to have_content 'vol.1'
            check('requestable_selected_23514405150006421')
            choose('requestable__delivery_mode_23514405150006421_print')
            expect(page).to have_content 'Pick-up location: Architecture Library'
            expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
          end
        end
      end

      it 'Handles a bad mfhd without system error' do
        visit 'requests/998574693506421?mfhd=abc123'
        expect(page).to have_content "Science"
      end

      it 'has firestone as the resource sharing deliveryt location' do
        visit 'http://localhost:3000/requests/99123713303506421?mfhd=22668310350006421'
        expect(page).to have_content 'Reconstructions : architecture and Blackness in America'
        expect(page).to have_content 'Request via Partner Library'
        expect(page).to have_content 'Pick-up location: Firestone Library'
      end
    end

    context 'A Princeton net ID user without a bibdata record' do
      let(:user) { FactoryBot.create(:user) }
      before do
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 404, body: invalid_patron_response, headers: {})
        login_as user
      end

      describe 'Visits a request page', js: true do
        it 'Tells the user their patron record is not available' do
          visit "/requests/99117809653506421?mfhd=22613352460006421"
          expect(a_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")).to have_been_made
          expect(page).to have_content(I18n.t("requests.account.auth_user_lookup_fail"))
        end
      end
    end

    context 'A barcode holding user' do
      let(:user) { FactoryBot.create(:valid_barcode_patron) }
      # change this back #438
      it 'displays a request form for a ReCAP item.' do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
        login_as user
        visit "/requests/#{mms_id}"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_selector '#request_user_barcode', visible: false
        expect(page).to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
      end
    end

    context 'A covid-trained pick-up only user' do
      let(:user) { FactoryBot.create(:user) }
      it 'displays a request form for a ReCAP item.' do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_barcode_patron_pick_up_only_response, headers: {})
        login_as user
        visit "/requests/#{mms_id}"
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_content('Physical Item Delivery')
        expect(page).to have_selector '#request_user_barcode', visible: false
      end
    end

    context 'An undergraduate student who has not taken the training' do
      let(:user) { FactoryBot.create(:user) }
      it 'displays a request form for a ReCAP item.' do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_no_campus_response, headers: {})
        login_as user
        visit "/requests/#{mms_id}"
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_selector '#request_user_barcode', visible: false
        expect(page).not_to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
        expect(page).not_to have_content('If you would like to have access to pick-up books')
      end
    end

    context 'An graduate student who has not taken the training' do
      let(:user) { FactoryBot.create(:user) }
      it 'displays a request form for a ReCAP item.' do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_graduate_student_no_campus_response, headers: {})
        login_as user
        visit "/requests/#{mms_id}"
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_content('Physical Item Delivery')
        expect(page).to have_selector '#request_user_barcode', visible: false
        expect(page).not_to have_content('You are not currently authorized for on-campus services at the Library. Please send an inquiry to refdesk@princeton.edu if you believe you should have access to these services.')
        expect(page).not_to have_content('If you would like to have access to pick-up books')
      end
    end

    context 'a princeton net ID user without a barcode' do
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
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_no_barcode_response, headers: {})
        login_as user
      end

      describe 'When visiting an Alma ID as a CAS User' do
        it 'disallows access to request an available ReCAP item.' do
          stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '32101095798938')
          visit "/requests/#{mms_id}"
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access to in process items' do
          visit "/requests/#{in_process_id}"
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access for in process recap items' do
          visit "/requests/#{recap_in_process_id}"
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access for On-Order recap items' do
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

        it 'disallows access of on on_shelf record' do
          stub_illiad_patron
          visit "/requests/9997708113506421?mfhd=22729045760006421"
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        let(:good_response) { fixture('/scsb_request_item_response.json') }
        it 'disallows access to request a physical recap item' do
          stub_scsb_availability(bib_id: "9999443553506421", institution_id: "PUL", barcode: '32101098722844')
          visit '/requests/9999443553506421?mfhd=22743365320006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access to request a Forrestal annex' do
          visit '/requests/999455503506421?mfhd=22642306790006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access to request a Lewis recap item digitally' do
          stub_scsb_availability(bib_id: "9970533073506421", institution_id: "PUL", barcode: '32101051217659')
          visit '/requests/9970533073506421?mfhd=22667391160006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access to request a digital copy from Lewis' do
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

        it 'allows filtering items by mfhd' do
          visit '/requests/9979171923506421?mfhd=22637778670006421'
          expect(page).not_to have_content 'Copy 2'
          expect(page).not_to have_content 'Copy 3'
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

        it 'disallows access to fillin forms in digital only' do
          visit 'requests/99105746993506421?mfhd=22547424510006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access ReCAP marqaund as an EDD option only' do
          stub_scsb_availability(bib_id: "99117809653506421", institution_id: "PUL", barcode: '32101106347378')
          visit '/requests/99117809653506421?mfhd=22613352460006421'
          expect(page).not_to have_button('Request this Item')
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
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
          visit '/requests/9973529363506421?mfhd=22667098990006421'
          expect(page).to have_content 'Request to View in Reading Room'
        end

        it 'allows guest patrons to see there are no items for Online only' do
          visit '/requests/9999946923506421?mfhd=22558528920006421'
          expect(page).to have_content 'there are no requestable items for this record'
        end

        it 'disallows access on Missing items' do
          visit '/requests/9917887963506421?mfhd=22503918400006421'
          expect(page).not_to have_content 'Electronic Delivery'
          expect(page).not_to have_content 'Physical Item Delivery'
          expect(page).to have_content 'You must register with the Library before you can request materials. Please go to Firestone Circulation for assistance. Thank you.'
          expect(page).not_to have_content 'Only items available for digitization can be requested when you do not have a barcode registered with the Library. Library staff will work to try to get you access to a digital copy of the desired material.'
        end

        it 'disallows access generic fill in requests enums from Annex or Firestone in mixed holding' do
          visit '/requests/9922868943506421?mfhd=22692156940006421'
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

    context 'An Alma user' do
      let(:alma_login_response) { fixture('/alma_login_response.json') }
      let(:user) { FactoryBot.create(:valid_alma_patron) }
      before do
        stub_request(:get, "#{Alma.configuration.region}/almaws/v1/users/#{user.uid}?expand=fees,requests,loans")
          .to_return(status: 200, headers: { "Content-Type" => ["application/json", "charset=UTF-8"] },
                     body: alma_login_response)
        login_as user
      end

      it "does not allow physical pickup request On Order SCSB Recap Item" do
        stub_scsb_availability(bib_id: "9994933183506421", institution_id: "PUL", barcode: '33333059902417')
        visit 'requests/SCSB-6710959'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'This item is not available'
      end

      it "allows a physical pickup request of ReCAP Item" do
        stub_scsb_availability(bib_id: "9941151723506421", institution_id: "PUL", barcode: '32101050751989')
        visit 'requests/9941151723506421?mfhd=22492702000006421'
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'Physical Item Delivery'
      end

      it "allows only physical pickup to enumerated annex item" do
        stub_alma_hold_success('9947220743506421', '22734584180006421', '23734584140006421', user.uid)

        visit "requests/9947220743506421?mfhd=22734584180006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'Physical Item Delivery'

        expect(page).to have_content "Department of Homeland Security appropriations for 2007"
        check('requestable_selected_23734584140006421')
        select('Firestone Library', from: 'requestable__pick_up_23734584140006421')
        page.find(".submit--request") # this is really strange, but if I find the button then I can click it in the next line...
        expect { click_button 'Request Selected Items' }.to change { ActionMailer::Base.deliveries.count }.by(2)
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
        visit "/requests/99113283293506421?mfhd=22750642660006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'This item is not available'
      end

      it "does not allow access to items on the shelf when available" do
        visit "requests/99125428126306421?mfhd=22910398870006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Request options for this item are only available to Faculty, Staff, and Students.'
        expect(page).to have_content 'Please proceed to Firestone Library - Classics Collection to retrieve this item'
      end

      it "does not allow access to items on the shelf when not available" do
        visit "requests/99125452799106421?mfhd=22917143470006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'This item is not available'
      end

      it "does not allow access to items on the shelf when enumerated" do
        visit "requests/998574693506421?mfhd=22579850750006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Request options for this item are only available to Faculty, Staff, and Students.'
      end

      it "allows access to in process items" do
        visit "requests/99124417723506421?mfhd=22689758840006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'In Process materials are typically available in several business days'
        expect(page).not_to have_content 'This item is not available'
        select('Firestone Library', from: 'requestable__pick_up_23922188050006421')
        expect { click_button 'Request this Item' }.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(page).to have_content I18n.t("requests.submit.in_process_success")
        email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        confirm_email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("In Process Request")
        expect(email.to).to eq(["fstcirc@princeton.edu"])
        expect(email.cc).to be_blank
        expect(email.html_part.body.to_s).to have_content("100 let na zashchite gosudarstva")
        expect(confirm_email.subject).to eq("In Process Request")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.to).to eq(["login@test.com"])
        expect(confirm_email.cc).to be_blank
        expect(confirm_email.html_part.body.to_s).to have_content("100 let na zashchite gosudarstva")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Remain only in the designated pick-up area")
      end

      it "allow requesting of available items and does not allow requesting of unavailable items" do
        availability_response = "[{\"itemBarcode\":\"32101108747674\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"},{\"itemBarcode\":\"32101108747666\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"},{\"itemBarcode\":\"32101108747658\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"},{\"itemBarcode\":\"32101108747682\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"}]"
        stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
          .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: { bibliographicId: "99125465081006421", institutionId: "PUL" })
          .to_return(status: 200, body: availability_response)

        visit "requests/99125465081006421?mfhd=22922148510006421"
        expect(page).not_to have_content 'Electronic Delivery'
        expect(page).to have_content 'Physical Item Delivery'
        expect(page).to have_content 'vol. 9 (1983)'
        expect(page).to have_content 'vol. 8 (1982)'
        expect(page).to have_content 'vol. 7 (1981)'
        expect(page).to have_content 'vol. 6 (1980)'
        expect(page).to have_content 'vol. 5 (1979)'
        expect(page).to have_content 'vol. 4 (1978)'
        within("#request_23922640720006421") do
          expect(page).to have_content 'In Process materials are typically available in several business days'
        end
        within("#request_23922148490006421") do
          expect(page).to have_content 'In Process materials are typically available in several business days'
        end
      end

      it "does not allow reuesting of on order books" do
        visit "requests/99125492003506421?mfhd=22927395910006421"
        expect(page).to have_content 'This item is not available'
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
# rubocop:enable Metrics/BlockLength
