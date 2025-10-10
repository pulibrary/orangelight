# frozen_string_literal: true
require 'rails_helper'

describe 'requests for Marquand items', type: :feature, requests: true do
  include ActiveJob::TestHelper

  let(:bib_id) { '9956200533506421' }
  let(:holding_id) { '2219823460006421' }
  let(:item_barcode) { '32101068477817' }
  let(:item_id) { '2319823440006421' }
  let(:location_code) { 'marquand$stacks' }
  let(:holdings_1display) do
    { "#{holding_id}":
      { 'location_code': location_code,
        'library': "Marquand Library",
        'items': [{ 'holding_id': holding_id,
                    'barcode': item_barcode }] } }.to_json
  end
  let(:catalog_raw) do
    { id: bib_id, title_citation_display: ["La Mirada : looking at photography in Latin America today"], holdings_1display: }.to_json
  end
  let(:catalog_raw_stub) do
    stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/#{bib_id}/raw")
      .to_return(status: 200, body: catalog_raw)
  end
  let(:availability) { [{ id: item_id, status_label: 'Available', location: location_code }].to_json }
  let(:availability_stub) do
    stub_request(:get, "#{Requests.config[:bibdata_base]}/bibliographic/#{bib_id}/holdings/#{holding_id}/availability.json")
      .to_return(status: 200, body: availability)
  end
  let(:bibdata_holding_response) do
    { code: "marquand$stacks", library: { code: "marquand" } }.to_json
  end
  let(:holding_location_stub) do
    stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/holding_locations/#{location_code}.json")
      .to_return(status: 200, body: bibdata_holding_response)
  end
  before do
    stub_holding_locations
    stub_delivery_locations
    catalog_raw_stub
    availability_stub
    holding_location_stub
  end

  context 'as a Princeton CAS user' do
    let(:user) { FactoryBot.create(:user) }
    let(:patron) { { barcode: "22101007797777", patron_group: 'P', netid: user.uid, active_email: "user@princeton.edu" }.to_json }
    let(:patron_stub) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: patron, headers: {})
    end

    before do
      patron_stub
      login_as user
    end

    after do
      clear_enqueued_jobs
    end

    context 'with an unavailable item' do
      let(:availability) { [{ status_label: 'Unavailable', location: location_code }].to_json }

      it 'does not give the option for ILL' do
        visit("requests/#{bib_id}?aeon=false&mfhd=#{holding_id}")
        expect(page).not_to have_content('Request via Partner Library')
        expect(page).to have_content('Email marquand@princeton.edu for access')
        expect(catalog_raw_stub).to have_been_requested
        expect(availability_stub).to have_been_requested
        expect(holding_location_stub).to have_been_requested
      end
    end
    context 'with a SCSB item' do
      let(:catalog_raw) do
        { id: bib_id, title_citation_display: ["La Mirada : looking at photography in Latin America today"],
          holdings_1display:, location_code_s: location_code }.to_json
      end
      let(:holdings_1display) do
        { "#{holding_id}":
          { 'location_code': location_code,
            'library': "Marquand Library",
            'items': [{ 'holding_id': holding_id,
                        'id': item_id,
                        'barcode': item_barcode }] } }.to_json
      end
      let(:location_code) { 'marquand$pj' }
      let(:bibdata_holding_response) do
        {
          code: "marquand$pj",
          recap_electronic_delivery_location: true,
          remote_storage: "recap_rmt",
          library: { code: "marquand" },
          holding_library: { code: 'marquand' }
        }.to_json
      end
      let(:scsb_post_stub) do
        stub_request(:post, "#{Requests.config[:scsb_base]}/requestItem/requestItem")
          .to_return(status: 200, body: good_response, headers: {})
      end
      let(:good_response) { file_fixture('../scsb_request_item_response.json') }
      before do
        scsb_post_stub
        stub_scsb_availability(bib_id:, institution_id: "PUL", barcode: item_barcode)
      end
      it 'is available for an EDD request or In Library Use (no physical delivery) at Marquand only' do
        visit("requests/#{bib_id}?mfhd=#{holding_id}")
        expect(page).to have_content I18n.t('requests.recap_edd.brief_msg')
        expect(page).to have_content 'Electronic Delivery'
        expect(page).to have_content 'Available for In Library Use'
        expect(page).to have_content 'Pick-up location: Marquand Library at Firestone'
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Article/Chapter Title (Required)'
      end
      it 'can be requested electronically' do
        visit("requests/#{bib_id}?mfhd=#{holding_id}")
        choose("requestable__delivery_mode_#{item_id}_edd") # chooses 'edd' radio button
        fill_in "Title", with: "my stuff"
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(scsb_post_stub).to have_been_requested
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("Electronic Document Delivery Request Confirmation")
        expect(email.html_part.body.to_s).to have_content("You will receive an email including a link where you can download your scanned section")
      end
      describe 'a hold from Alma' do
        before do
          stub_alma_hold_success(bib_id, holding_id, item_id, user.uid)
        end
        it 'can be requested for in library use' do
          visit("requests/#{bib_id}?mfhd=#{holding_id}")
          choose("requestable__delivery_mode_#{item_id}_in_library") # chooses 'in_library' radio button
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(scsb_post_stub).to have_been_requested
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content("Once we complete our processing, you'll receive an email")
          expect(confirm_email.html_part.body.to_s).to have_content("La Mirada")
        end
      end

      context 'with an on-order item' do
        let(:availability) { [{ id: item_id, status: 'Unavailable', status_label: 'Acquisition', location: location_code }].to_json }
        let(:bibdata_holding_response) do
          { code: "marquand$pj", library: { code: "marquand" }, delivery_locations: [{ library: { code: 'marquand' } }] }.to_json
        end
        it 'allows a user to request the item' do
          visit("requests/#{bib_id}?mfhd=#{holding_id}")
          expect(page).to have_content 'Pick-up location: Marquand Library at Firestone'
          expect(page).to have_content 'On Order books have not yet been received. Place a request to be notified when this item has arrived and is ready for your pick-up.'
          check "requestable_selected_#{item_id}"
          click_button 'Request this Item'
          expect(page).to have_content 'Request submitted'
          scsb_url = "#{Requests.config[:scsb_base]}/requestItem/requestItem"
          expect(a_request(:post, scsb_url)).not_to have_been_made
        end
      end
    end
    context 'with a non-circulating item' do
      context 'with no item data' do
        let(:availability) { [].to_json }
        let(:catalog_raw) do
          { id: bib_id, holdings_1display:, title_citation_display: ["La Mirada : looking at photography in Latin America today"] }.to_json
        end
        let(:holdings_1display) do
          { "#{holding_id}":
            { 'location_code': location_code,
              'library': "Marquand Library" } }.to_json
        end

        before do
          stub_illiad_patron(uid: user.uid)
          stub_illiad_request(uid: user.uid)
          stub_illiad_note
        end

        it 'can be digitized' do
          visit("requests/#{bib_id}?mfhd=#{holding_id}")
          choose("requestable__delivery_mode_#{holding_id}_edd")
          expect(page).to have_content I18n.t('requests.marquand_edd.brief_msg')
          expect(page).to have_content 'Electronic Delivery'
          expect(page).to have_content 'Unavailable'
          expect(page).not_to have_content 'Available for In Library Use'
          fill_in "Article/Chapter Title", with: "ABC"
          fill_in "Author", with: "I Aman Author"
          expect do
            click_button 'Request this Item'
          end.to change { ActionMailer::Base.deliveries.count }.by(2)
          expect(stub_illiad_patron(uid: user.uid)).to have_been_requested
          expect(stub_illiad_request(uid: user.uid)).to have_been_requested
          expect(stub_illiad_note).to have_been_requested
          confirm_email = ActionMailer::Base.deliveries.last
          expect(confirm_email.subject).to eq("Electronic Document Delivery Request Confirmation")
          expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
          expect(confirm_email.html_part.body.to_s).to have_content(I18n.t('requests.marquand_edd.email_conf_msg'))
          expect(confirm_email.html_part.body.to_s).to have_content("La Mirada : looking at photography in Latin America today")
          marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
          expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan")
          expect(marquand_email.html_part.body.to_s).to have_content("La Mirada : looking at photography in Latin America today")
          expect(marquand_email.html_part.body.to_s).to have_content("ABC")
          expect(marquand_email.html_part.body.to_s).to have_content("I Aman Author")
          expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
          expect(marquand_email.cc).to be_blank
        end
      end
    end
    context 'with an In Library Use item' do
      let(:catalog_raw) do
        { id: bib_id, holdings_1display:, title_citation_display: ["La Mirada : looking at photography in Latin America today"] }.to_json
      end
      before do
        stub_alma_hold_success(bib_id, holding_id, item_id, user.uid)
      end

      it 'places a hold in Alma and sends emails to marquand offsite' do
        visit("requests/#{bib_id}?mfhd=#{holding_id}")
        expect(page).not_to have_content 'Physical Item Delivery'
        expect(page).to have_content 'Available for In Library Use'
        expect(page).to have_content 'Electronic Delivery'
        expect(page).not_to have_link('make an appointment')
        choose("requestable__delivery_mode_#{item_id}_in_library") # chooses 'in library' radio button
        expect(page).to have_content('Marquand Library at Firestone')
        expect do
          click_button 'Request this Item'
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        confirm_email = ActionMailer::Base.deliveries.last
        expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
        expect(confirm_email.html_part.body.to_s).to have_content("you will receive an email when the book is available for consultation")
        expect(confirm_email.html_part.body.to_s).not_to have_content("Pick-up By")
        expect(confirm_email.html_part.body.to_s).to have_content("La Mirada : looking at photography in Latin America today")
        marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
        expect(marquand_email.subject).to eq("Patron Initiated Catalog Request In Library")
        expect(marquand_email.html_part.body.to_s).to have_content("La Mirada : looking at photography in Latin America today")
        expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
        expect(marquand_email.cc).to be_blank
      end
      context 'at Clancy' do
        let(:availability) { [{ id: item_id, status_label: 'Available', location: location_code, barcode: item_barcode }].to_json }

        before do
          stub_clancy_status(barcode: item_barcode, status: "Item In at Rest")
          stub_clancy_post(barcode: item_barcode)
        end
        describe 'requesting a physical item' do
          it "places a hold in Alma and a Clancy request" do
            visit("requests/#{bib_id}?mfhd=#{holding_id}")
            expect(page).not_to have_content 'Physical Item Delivery'
            expect(page).to have_content 'Electronic Delivery'
            expect(page).to have_content 'Available for In Library Use'
            expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
            expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
            choose("requestable__delivery_mode_#{item_id}_in_library") # chooses 'in_library' radio button
            expect do
              click_button 'Request this Item'
            end.to change { ActionMailer::Base.deliveries.count }.by(2)
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Patron Initiated Catalog Request In Library Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.html_part.body.to_s).to have_content("La Mirada")
            marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
            expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy In Library")
            expect(marquand_email.html_part.body.to_s).to have_content("La Mirada")
            expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
            expect(marquand_email.cc).to be_blank
          end
        end
        describe 'requesting an electronic item' do
          before do
            stub_clancy_status(barcode: item_barcode, status: "Item In at Rest")
            stub_illiad_patron(uid: user.uid)
            stub_illiad_request(uid: user.uid)
            stub_illiad_note
          end
          it 'places an illiad request' do
            visit("requests/#{bib_id}?mfhd=#{holding_id}")
            expect(page).not_to have_content 'Physical Item Delivery'
            expect(page).to have_content 'Electronic Delivery'
            expect(page).to have_content 'Available for In Library Use'
            expect(page).to have_content I18n.t("requests.clancy_in_library.brief_msg")
            expect(page).to have_content('Pick-up location: Marquand Library at Firestone')
            choose("requestable__delivery_mode_#{item_id}_edd") # chooses 'edd' radio button
            expect(page).to have_content I18n.t('requests.clancy_edd.brief_msg')
            expect(page).to have_content I18n.t("requests.clancy_edd.note_msg")
            fill_in "Article/Chapter Title", with: "ABC"
            expect do
              click_button 'Request this Item'
            end.to change { ActionMailer::Base.deliveries.count }.by(2)
            expect(stub_illiad_patron(uid: user.uid)).to have_been_requested
            expect(stub_illiad_request(uid: user.uid)).to have_been_requested
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.html_part.body.to_s).to have_content("La Mirada")
            expect(confirm_email.html_part.body.to_s).to have_content("Electronic document delivery requests typically take 4-8 business days")
            marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
            expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Clancy Scan")
            expect(marquand_email.html_part.body.to_s).to have_content("La Mirada")
            expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
            expect(marquand_email.cc).to be_blank
          end
        end
        context 'that is unavailable' do
          before do
            stub_clancy_status(barcode: item_barcode, status: "Item In Accession Process")
            stub_illiad_patron(uid: user.uid)
            stub_illiad_request(uid: user.uid)
            stub_illiad_note
          end

          it "only has edd as an option" do
            visit("requests/#{bib_id}?mfhd=#{holding_id}")
            expect(page).not_to have_content 'Physical Item Delivery'
            expect(page).not_to have_content 'Available for In Library Use'
            expect(page).to have_content 'Electronic Delivery'
            choose("requestable__delivery_mode_#{item_id}_edd") # chooses 'edd' radio button
            expect(page).to have_content I18n.t('requests.clancy_unavailable_edd.brief_msg')
            expect(page).to have_content I18n.t("requests.clancy_unavailable_edd.note_msg")
            fill_in "Article/Chapter Title", with: "ABC"
            expect(page).not_to have_content("translation missing")
            expect do
              click_button 'Request this Item'
            end.to change { ActionMailer::Base.deliveries.count }.by(2)
            expect(stub_illiad_patron(uid: user.uid)).to have_been_requested
            expect(stub_illiad_request(uid: user.uid)).to have_been_requested
            confirm_email = ActionMailer::Base.deliveries.last
            expect(confirm_email.subject).to eq("Patron Initiated Catalog Request EDD Confirmation")
            expect(confirm_email.html_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.text_part.body.to_s).not_to have_content("translation missing")
            expect(confirm_email.html_part.body.to_s).to have_content("La Mirada")
            expect(confirm_email.html_part.body.to_s).to have_content(I18n.t("requests.clancy_unavailable_edd.email_conf_msg"))
            expect(confirm_email.html_part.body.to_s).to have_content("ABC")
            marquand_email = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
            expect(marquand_email.subject).to eq("Patron Initiated Catalog Request Scan - Unavailable at Clancy")
            expect(marquand_email.html_part.body.to_s).to have_content("La Mirada")
            expect(marquand_email.html_part.body.to_s).to have_content("ABC")
            expect(marquand_email.to).to eq(["marquandoffsite@princeton.edu"])
            expect(marquand_email.cc).to be_blank
          end
        end
      end
    end
  end
end
