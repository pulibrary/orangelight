# frozen_string_literal: true
require 'rails_helper'
require "mail"

describe Requests::RequestController, type: :controller, vcr: { cassette_name: 'request_controller', record: :none } do
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }
  let(:user) { FactoryBot.create(:user) }

  describe 'POST #generate' do
    before do
      sign_in(user)
    end
    it 'handles access patron params when the user form is posted' do
      post :generate, params: { request: { username: 'foobar', email: 'foo@bar.com' },
                                source: 'pulsearch',
                                system_id: '9963773693506421', mfhd: '22239658680006421' }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #generate' do
    context "A valid user" do
      before do
        sign_in(user)
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
          .to_return(status: 200, body: valid_patron_response, headers: {})
      end

      it 'sets the current request mode to trace when supplied' do
        stub_scsb_availability(bib_id: "9996764833506421", institution_id: "PUL", barcode: '32101099103457')
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9996764833506421',
          mfhd: '2275983490006421',
          mode: "trace"
        }
        expect(assigns(:mode)).to eq('trace')
      end
      it 'uses the default request mode and does not set a flash' do
        stub_scsb_availability(bib_id: "9996764833506421", institution_id: "PUL", barcode: '32101099103457')
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9996764833506421',
          mfhd: '2275983490006421'
        }
        expect(flash.now[:notice]).to be_blank
        expect(assigns(:mode)).to eq('standard')
      end
      it 'redirects you when a thesis record is requested' do
        bib_id = 'dsp01rr1720547'
        stub_catalog_raw(bib_id:, type: 'theses_and_dissertations')

        get :generate, params: {
          source: 'pulsearch',
          system_id: bib_id,
          mfhd: 'thesis'
        }
        expect(response.status).to eq(302)
      end
      it 'redirects you when a single aeon record is requested' do
        stub_holding_locations
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9995768803506421',
          mfhd: '22497016220006421'
        }
        expect(response.status).to eq(302)
      end
      xit 'redirects you when an aeon record with over 500 items is requested' do
        stub_holding_locations
        stub_single_holding_location('rare$hsve')
        stub_catalog_raw(bib_id: '9930682063506421')
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9930682063506421',
          mfhd: '22707844130006421'
        }
        expect(response.status).to eq(302)
      end

      it 'does not redirect you when multiple aeon records are requested' do
        get :generate, params: {
          source: 'pulsearch',
          system_id: '9995768803506421',
          mfhd: '2298692650006421'
        }
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'POST #submit' do
    let(:user_info) do
      {
        "patron_id" => "12345",
        "patron_group" => "staff",
        "user_name" => "Foo Request",
        "user_barcode" => "22101007797777",
        "email" => "foo@princeton.edu",
        "source" => "pulsearch"
      }.with_indifferent_access
    end
    let(:requestable) do
      [
        {
          "selected" => "true",
          "bibid" => "9995904203506421",
          "mfhd" => "2297676790006421",
          "call_number" => "PN1995.9.A76 P7613 2015",
          "location_code" => "rcppj",
          "item_id" => "7391704",
          "barcode" => "32101098797010",
          "copy_number" => "0",
          "status" => "Not Charged",
          "pick_up" => "",
          "type" => "recap",
          "edd_art_title" => "test",
          "edd_start_page" => "1",
          "edd_end_page" => "1",
          "edd_volume_number" => "1",
          "edd_issue" => "1",
          "edd_author" => "",
          "edd_note" => ""
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9995904203506421"
      }.with_indifferent_access
    end

    # rubocop:disable RSpec/VerifiedDoubles
    let(:mail_message) { double(::Mail::Message) }
    # rubocop:enable RSpec/VerifiedDoubles

    before do
      sign_in(user)
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      without_partial_double_verification do
        allow(mail_message).to receive(:deliver_now).and_return(nil)
      end
    end

    context "recap requestable" do
      let(:recap) { instance_double(Requests::Submissions::Recap, errors: [], handle: {}, service_type: 'recap_edd', success_message: 'success!') }
      it 'contacts recap and sends email' do
        requestable.first["library_code"] = "recap"
        requestable.first["delivery_mode_7391704"] = "edd"
        expect(Requests::Submissions::Recap).to receive(:new).with(anything, service_type: 'recap_edd').and_return(recap)
        expect(recap).to receive(:send_mail)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "recap_no_items requestable" do
      let(:generic) { instance_double(Requests::Submissions::Generic, errors: [], handle: {}, service_type: 'recap_no_items', success_message: 'success!') }
      it 'sends email and confirmation email' do
        requestable.first["type"] = "recap_no_items"
        requestable.first["pick_up"] = { pick_up: "PA", pick_up_location_code: "firestone" }.to_json
        expect(Requests::Submissions::Generic).to receive(:new).with(anything, service_type: 'recap_no_items').and_return(generic)
        expect(generic).to receive(:send_mail)
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
      end
    end

    context "invalid submission" do
      it 'returns an error' do
        requestable.first.delete("edd_art_title")
        requestable.first["edd_art_title"] = ""
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
        expect(response.status).to eq(200)
        expect(flash[:error]).to eq('We were unable to process your request. Correct the highlighted errors.')
      end
    end

    context "service error" do
      it 'returns and error' do
        requestable.first["library_code"] = "recap"
        requestable.first["delivery_mode_7391704"] = "edd"
        post :submit, params: { "request" => user_info,
                                "requestable" => requestable,
                                "bib" => bib, "format" => "js" }
        expect(response.status).to eq(200)
        expect(flash[:error]).to eq("There was a problem with this request which Library staff need to investigate. You'll be notified once it's resolved and requested for you.")
      end
    end
    describe 'allowed params' do
      context 'valid params' do
        let(:bib) do
          {
            "id" => "9995904203506421",
            "date" => "2025"
          }.with_indifferent_access
        end
        it 'passes all valid bib params to Requests::Submission' do
          expected_bib = { 'id' => '9995904203506421', 'date' => '2025' }
          expect(Requests::Submission).to receive(:new) do |args|
            expect(args.to_h['bib']).to eq(expected_bib)
          end.and_call_original
          post :submit, params: {
            "request" => user_info,
            "bib" => bib,
            "requestable" => requestable,
            "format" => "js"
          }
        end
      end
      context 'invalid params' do
        let(:bib) do
          {
            "id" => "9995904203506421",
            "not_metadata" => "some+random+content"
          }.with_indifferent_access
        end
        it 'does not pass the invalid params to Requests::Submission' do
          expected_bib = { 'id' => '9995904203506421' }
          expect(Requests::Submission).to receive(:new) do |args|
            expect(args.to_h['bib']).to eq(expected_bib)
          end.and_call_original
          post :submit, params: {
            "request" => user_info,
            "bib" => bib,
            "requestable" => requestable,
            "format" => "js"
          }
        end
      end
    end
  end

  describe 'GET #index' do
    it 'redirects to the root url' do
      get :index
      expect(response).to redirect_to("/")
    end
  end
end
