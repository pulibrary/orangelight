# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples "can request", vcr: { cassette_name: 'request_features', record: :none } do
    let(:mms_id) { '9994933183506421?mfhd=22558528920006421' }
    let(:user) { FactoryBot.create(:user) }

    before do
        login_as user
    end

    it "PUL ReCAP print item" do
        stub_catalog_raw(bib_id: '9994933183506421')
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
        expect(page).to have_selector '#request_user_barcode', visible: :hidden
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

end

describe 'Faculty and Professional (P)' do
    let(:patron_response) { fixture('/bibdata/patron/faculty.json') }
    let(:good_response) { fixture('/scsb_request_item_response.json') }
    it_behaves_like "can request"
end

describe 'Regular Staff (REG)' do
end

describe 'Graduate Student (GRAD)' do
end

describe 'Senior Undergraduate (SENR)' do
end

describe 'Undergraduate (UGRAD)' do
end

describe 'Faculty Affiliate (Affiliate-P)' do
    context 'when logging in using a NetID in CAS' do
    end
    context 'when logging in using Alma' do
    end
end

describe 'Affiliate (Affiliate)' do
    context 'when logging in using a NetID in CAS' do
    end
    context 'when logging in using Alma' do
    end
end

describe 'Guest Patron (GST)' do
end

describe 'Casual Hourly (CASUAL)' do
end
