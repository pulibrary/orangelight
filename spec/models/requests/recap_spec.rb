require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
describe Requests::Submissions::Recap do
  context 'ReCAP Request' do
    let(:valid_patron) { { "netid" => "foo", "university_id" => "99999999", "active_email" => 'foo1@princeton.edu', barcode: '111222333' }.with_indifferent_access }
    let(:user_info) do
      user = instance_double(User, guest?: false, uid: 'foo')
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end
    let(:scsb_url) { "#{Requests::Config[:scsb_base]}/requestItem/requestItem" }
    let(:alma_url) { "#{Alma.configuration.region}/almaws/v1/bibs/#{bib['id']}/holdings/#{requestable[0]['mfhd']}/items/#{requestable[0]['item_id']}/requests?user_id=99999999" }
    let(:alma2_url) { "#{Alma.configuration.region}/almaws/v1/bibs/#{bib['id']}/holdings/#{requestable[1]['mfhd']}/items/#{requestable[1]['item_id']}/requests?user_id=99999999" }

    let(:requestable) do
      [{ "selected" => "true",
         "mfhd" => "22113812720006421",
         "call_number" => "HA202 .U581",
         "location_code" => "recap$pa",
         "item_id" => "23113812570006421",
         "barcode" => "32101082413400",
         "enum_display" => "1956",
         "copy_number" => "1",
         "status" => "Not Charged",
         "type" => "recap",
         "delivery_mode_23113812570006421" => "print",
         "edd_start_page" => "",
         "edd_end_page" => "",
         "edd_volume_number" => "",
         "edd_issue" => "",
         "edd_author" => "",
         "edd_art_title" => "",
         "edd_note" => "",
         "library_code" => "recap",
         "pick_up" => "PA",
         "pick_up_location_code" => 'firestone' },
       { "selected" => "true",
         "mfhd" => "22113812720006421",
         "call_number" => "HA202 .U581",
         "location_code" => "recap$pa",
         "item_id" => "23113812580006421",
         "barcode" => "32101094934260",
         "enum_display" => "1947",
         "copy_number" => "1",
         "status" => "Not Charged",
         "type" => "recap",
         "delivery_mode_23113812580006421" => "edd",
         "edd_start_page" => "1",
         "edd_end_page" => "",
         "edd_volume_number" => "",
         "edd_issue" => "",
         "edd_author" => "",
         "edd_art_title" => "Baz",
         "edd_note" => "",
         "library_code" => "recap",
         "pick_up" => "PH",
         "pick_up_location_code" => 'mudd' }]
    end

    let(:bib) do
      {
        "id" => "994916543506421",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
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
      Requests::Submission.new(params, user_info)
    end

    let(:recap_request) { described_class.new(submission) }
    let(:recap_edd_request) { described_class.new(submission, service_type: 'recap_edd') }
    let(:good_request) { fixture('/scsb_find_request.json') }
    let(:good_response) { fixture('/scsb_request_item_response.json') }
    let(:bad_response) { fixture('/scsb_request_item_response_errors.json') }

    describe 'All ReCAP Requests' do
      it "captures recap errors when the request is unsuccessful or malformed." do
        stub_request(:post, scsb_url).
          # with(headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 401, body: "Unauthorized", headers: {})
        expect { recap_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_request.submitted.size).to eq(0)
        expect(recap_request.errors.size).to eq(1)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma_url)).not_to have_been_made
        expect(a_request(:post, alma2_url)).not_to have_been_made
      end

      it "captures recap edd errors when the request is unsuccessful or malformed." do
        stub_request(:post, scsb_url).
          # with(headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 401, body: "Unauthorized", headers: {})
        expect { recap_edd_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_edd_request.submitted.size).to eq(0)
        expect(recap_edd_request.errors.size).to eq(1)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma_url)).not_to have_been_made
        expect(a_request(:post, alma2_url)).not_to have_been_made
      end

      it "captures errors when response is a 200 but the request is unsuccessful" do
        stub_request(:post, scsb_url).
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: bad_response, headers: {})
        expect { recap_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_request.submitted.size).to eq(0)
        expect(recap_request.errors.size).to eq(1)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma_url)).not_to have_been_made
        expect(a_request(:post, alma2_url)).not_to have_been_made
      end

      it "captures successful request submission" do
        stub_request(:post, scsb_url).
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, alma_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        expect { recap_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_request.submitted.size).to eq(1)
        expect(recap_request.errors.size).to eq(0)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma_url)).to have_been_made
      end

      it "captures successful edd request submission" do
        stub_request(:post, scsb_url).
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, alma_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        expect { recap_edd_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_edd_request.submitted.size).to eq(1)
        expect(recap_edd_request.errors.size).to eq(0)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma2_url)).not_to have_been_made # no alma hold for edd
      end

      it "captures errors in the alma hold request" do
        stub_request(:post, scsb_url).
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, alma_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 400, body: fixture("alma_hold_error_no_library_response.json"), headers: { 'content-type': 'application/json' })
        expect { recap_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(recap_request.submitted.size).to eq(1)
        expect(recap_request.errors.size).to eq(0)
        expect(a_request(:post, scsb_url)).to have_been_made.once
        expect(a_request(:post, alma_url)).to have_been_made
        error_email = ActionMailer::Base.deliveries.last
        expect(error_email.subject).to eq("Request Service Error")
        expect(error_email.html_part.body.to_s).not_to include("translation missing")
        expect(error_email.text_part.body.to_s).not_to include("translation missing")
        expect(error_email.to).to eq(["recapproblems@princeton.edu"])
        expect(error_email.cc).to be_blank
        expect(error_email.html_part.body.to_s).to include("Recap request was successful, but creating the hold in Alma had an error: Can not create hold")
        expect(error_email.html_part.body.to_s).to include("foo")
        expect(error_email.html_part.body.to_s).to include("foo1@princeton.edu")
        expect(error_email.html_part.body.to_s).to include("111222333")
        expect(error_email.text_part.body.to_s).to include("foo")
        expect(error_email.text_part.body.to_s).to include("foo1@princeton.edu")
        expect(error_email.text_part.body.to_s).to include("111222333")
      end

      context 'when the SCSB web service responds with an invalid response' do
        subject(:recap) { described_class.new(submission) }

        it 'logs an error' do
          stub_request(:post, scsb_url).to_return(status: 200, body: '{invalid', headers: {})
          allow(Rails.logger).to receive(:error)

          expect { recap.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
          expect(recap.submitted.size).to eq(0)
          expect(recap.errors.size).to eq(1)
          expect(Rails.logger).to have_received(:error).with(/Invalid response from the SCSB server/).once
          expect(a_request(:post, scsb_url)).to have_been_made.once
          expect(a_request(:post, alma_url)).not_to have_been_made
        end
      end
    end
  end

  context 'ReCAP SCSB Print Request' do
    let(:valid_patron) { { "netid" => "foo", "university_id" => "99999999" }.with_indifferent_access }
    let(:user_info) do
      user = instance_double(User, guest?: false, uid: 'foo')
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end
    let(:scsb_url) { "#{Requests::Config[:scsb_base]}/requestItem/requestItem" }
    let(:alma_url) { "#{Alma.configuration.region}/almaws/v1/bibs/#{bib['id']}/holdings/#{requestable[0]['mfhd']}/items/#{requestable[0]['item_id']}/requests?user_id=99999999" }
    let(:alma2_url) { "#{Alma.configuration.region}/almaws/v1/bibs/#{bib['id']}/holdings/#{requestable[1]['mfhd']}/items/#{requestable[1]['item_id']}/requests?user_id=99999999" }

    let(:requestable) do
      [{ "selected" => "true",
         "mfhd" => "22113812720006421",
         "call_number" => "HA202 .U581",
         "location_code" => "recap$pa",
         "item_id" => "23113812570006421",
         "barcode" => "32101082413400",
         "enum_display" => "1956",
         "copy_number" => "1",
         "status" => "Not Charged",
         "type" => "recap",
         "delivery_mode_23113812570006421" => "print",
         "edd_start_page" => "",
         "edd_end_page" => "",
         "edd_volume_number" => "",
         "edd_issue" => "",
         "edd_author" => "",
         "edd_art_title" => "",
         "edd_note" => "",
         "library_code" => "recap",
         "pick_up" => "PA",
         "pick_up_location_code" => 'firestone' },
       { "selected" => "true",
         "mfhd" => "22113812720006421",
         "call_number" => "HA202 .U581",
         "location_code" => "scsbcul",
         "item_id" => "23113812580006421",
         "barcode" => "32101094934260",
         "enum_display" => "1947",
         "copy_number" => "1",
         "status" => "Not Charged",
         "type" => "recap",
         "delivery_mode_23113812580006421" => "print",
         "edd_start_page" => "",
         "edd_end_page" => "",
         "edd_volume_number" => "",
         "edd_issue" => "",
         "edd_author" => "",
         "edd_art_title" => "",
         "edd_note" => "",
         "library_code" => "recap",
         "pick_up" => "PH",
         "pick_up_location_code" => 'mudd' }]
    end

    let(:bib) do
      {
        "id" => "994916543506421",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
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
      Requests::Submission.new(params, user_info)
    end

    let(:recap_request) { described_class.new(submission) }
    let(:good_request) { fixture('/scsb_find_request.json') }
    let(:good_response) { fixture('/scsb_request_item_response.json') }

    describe 'All ReCAP Requests' do
      it "captures successful request submissions." do
        stub_request(:post, scsb_url).
          # with(body: good_request, headers: { 'Accept' => '*/*', 'Content-Type' => "application/json", 'api_key' => 'TESTME' }).
          to_return(status: 200, body: good_response, headers: {})
        stub_request(:post, alma_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "firestone"))
          .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        stub_request(:post, alma2_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "mudd"))
          .to_return(status: 200, body: fixture("alma_hold_response.json"), headers: { 'content-type': 'application/json' })
        expect { recap_request.handle }.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(recap_request.submitted.size).to eq(2)
        expect(recap_request.errors.size).to eq(0)
        expect(a_request(:post, scsb_url)).to have_been_made.twice
        expect(a_request(:post, alma_url)).to have_been_made
        expect(a_request(:post, alma2_url)).not_to have_been_made
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
