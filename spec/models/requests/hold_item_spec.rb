# frozen_string_literal: true
require 'rails_helper'

describe Requests::Submissions::HoldItem, type: :controller do
  context 'Hold Item Request' do
    let(:valid_patron) { { "netid" => "foo", university_id: "99999999" }.with_indifferent_access }
    let(:user_info) do
      user = instance_double(User, guest?: false, uid: 'foo')
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end

    let(:requestable) do
      [{ "selected" => "true",
         "mfhd" => "22212632750006421",
         "call_number" => "HQ1532 .P44 2019",
         "location_code" => "f",
         "item_id" => "23212632740006421",
         "barcode" => "32101107924928",
         "copy_number" => "0",
         "status" => "Not Charged",
         "item_type" => "Gen",
         "pick_up_location_code" => "fcirc",
         "pick_up_location_id" => "489",
         "type" => "on_shelf" }]
    end

    let(:bib) do
      {
        "id" => "99114518363506421",
        "title" => "Beautiful evidence",
        "author" => "Tufte, Edward R.",
        "date" => "2006"
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

    let(:todays_date) { Time.zone.today }
    let(:hold_request) { described_class.new(submission) }

    let(:responses) do
      {
        error: fixture("alma_hold_error_response.json"),
        error_malformed: fixture("alma_hold_error_no_library_response.json"),
        success: fixture("alma_hold_response.json")
      }
    end

    describe 'All Hold Requests' do
      let(:stub_url) do
        "#{Alma.configuration.region}/almaws/v1/bibs/#{submission.bib['id']}/holdings/#{submission.items[0]['mfhd']}/items/#{submission.items[0]['item_id']}/requests?user_id=99999999"
      end

      it "captures errors when the request is repeated." do
        stub_request(:post, stub_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "fcirc"))
          .to_return(status: 200, body: responses[:error], headers: { 'content-type': 'application/json' })
        hold_request.handle
        expect(hold_request.submitted.size).to eq(1)
        expect(hold_request.errors.size).to eq(0)
        expect(hold_request).to be_duplicate
      end

      it "captures errors when the request is malformed" do
        stub_request(:post, stub_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "fcirc"))
          .to_return(status: 400, body: responses[:error_malformed], headers: { 'content-type': 'application/json' })
        hold_request.handle
        expect(hold_request.submitted.size).to eq(0)
        expect(hold_request.errors.size).to eq(1)
        expect(hold_request.errors.first[:create_hold][:note]).to eq('Hold can not be created')
      end

      it "captures successful request submissions." do
        stub_request(:post, stub_url)
          .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "fcirc"))
          .to_return(status: 200, body: responses[:success], headers: { 'content-type': 'application/json' })
        hold_request.handle
        expect(hold_request.submitted.size).to eq(1)
        expect(hold_request.errors.size).to eq(0)
        expect(hold_request.submitted.first[:payload][:pickup_location_library]).to eq('fcirc')
        expect(hold_request.submitted.first[:response]["request_id"]).to eq('9999989180006421')
      end

      context "no pick-up id is present" do
        let(:requestable) do
          [{ "selected" => "true",
             "mfhd" => "22212632750006421",
             "call_number" => "HQ1532 .P44 2019",
             "location_code" => "f",
             "item_id" => "23212632740006421",
             "barcode" => "32101107924928",
             "copy_number" => "0",
             "status" => "Not Charged",
             "item_type" => "Gen",
             "pick_up_location_code" => "fcirc",
             "pick_up" => "PM",
             "type" => "on_shelf" }]
        end

        it 'has the correct pick-up location id' do
          stub_request(:post, stub_url)
            .with(body: hash_including(request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: "fcirc"))
            .to_return(status: 200, body: responses[:success], headers: { 'content-type': 'application/json' })
          hold_request.handle
          expect(hold_request.submitted.first[:payload][:pickup_location_library]).to eq('fcirc')
        end
      end
    end
  end
end
