# frozen_string_literal: true
require 'rails_helper'

describe Requests::ClancyItem do
  let(:connection) { Faraday.new("http://example.com") }
  let(:clancy_item) { described_class.new(barcode: "1234565", connection: connection) }
  before do
    allow(connection).to receive(:get).and_return(response)
  end
  context 'Available item' do
    let(:response) { instance_double "Faraday::Response", "success?": true, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"1234565\",\"status\":\"Item In at Rest\"}" }

    describe '#status' do
      it "is has the status json" do
        expect(clancy_item.status["success"]).to be_truthy
        expect(clancy_item.status["status"]).to eq("Item In at Rest")
        expect(clancy_item.errors).to be_empty
      end
    end

    describe '#not_at_clancy?' do
      it "is not_at_clancy? to be false" do
        expect(clancy_item.not_at_clancy?).to be_falsey
      end
    end

    describe '#available?' do
      it "is available" do
        expect(clancy_item.available?).to be_truthy
      end
    end

    describe '#request' do
      let(:response) { instance_double "Faraday::Response", "success?": true, body: "{\"success\":true,\"error\":\"\",\"request_count\":\"1\",\"results\":[{\"item\":\"32101068477817\",\"deny\":\"N\",\"istatus\":\"Item Requested\"}]}" }
      let(:user) { FactoryBot.build(:user) }
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777",
          "university_id" => "9999999", "patron_group" => "staff", "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
      end
      let(:patron) do
        Requests::Patron.new(user: user, session: {}, patron: valid_patron)
      end

      before do
        allow(connection).to receive(:post).and_return(response)
      end

      it "responds with success" do
        expect(clancy_item.request(patron: patron, hold_id: 'hold_id')).to be_truthy
      end

      context "request denied" do
        let(:response) { instance_double "Faraday::Response", "success?": true, body: "{\"success\":true,\"error\":\"\",\"request_count\":\"1\",\"results\":[{\"item\":\"32101068477817\",\"deny\":\"Y\",\"istatus\":\"Item Restricted from this API Key\"}]}" }
        it "responds with error" do
          expect(clancy_item.request(patron: patron, hold_id: 'hold_id')).to be_falsey
        end
      end
    end
  end

  context 'Unavailable item' do
    let(:response) { instance_double "Faraday::Response", "success?": true, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"1234565\",\"status\":\"Out on Physical Retrieval\"}" }

    describe '#status' do
      it "is has the status json" do
        expect(clancy_item.status["success"]).to be_truthy
        expect(clancy_item.status["status"]).to eq("Out on Physical Retrieval")
        expect(clancy_item.errors).to be_empty
      end
    end

    describe '#not_at_clancy?' do
      it "is not_at_clancy? to be false" do
        expect(clancy_item.not_at_clancy?).to be_falsey
      end
    end

    describe '#available?' do
      it "is not available" do
        expect(clancy_item.available?).to be_falsey
      end
    end
  end

  context 'Item not in the Clancy facility' do
    let(:response) { instance_double "Faraday::Response", "success?": true, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"1234565\",\"status\":\"Item not Found\"}" }

    describe '#status' do
      it "is has the status json" do
        expect(clancy_item.status["success"]).to be_truthy
        expect(clancy_item.status["status"]).to eq("Item not Found")
        expect(clancy_item.errors).to be_empty
      end
    end

    describe '#not_at_clancy?' do
      it "is not_at_clancy" do
        expect(clancy_item.not_at_clancy?).to be_truthy
      end
    end

    describe '#available?' do
      it "is not available" do
        expect(clancy_item.available?).to be_falsey
      end
    end
  end

  context 'Error accessing clancy api' do
    let(:response) { instance_double "Faraday::Response", "success?": false, status: 403, body: "{\"success\":false,\"error\":\"Invalid API Key\"}" }

    describe '#status' do
      it "is has the status json" do
        expect(clancy_item.status["success"]).to be_falsey
        expect(clancy_item.errors).to eq(["Error connecting with Clancy: 403"])
      end
    end

    describe '#not_at_clancy?' do
      it "is not_at_clancy" do
        expect(clancy_item.not_at_clancy?).to be_truthy
      end
    end

    describe '#available?' do
      it "is not available" do
        expect(clancy_item.available?).to be_falsey
      end
    end

    describe '#request' do
      let(:user) { FactoryBot.build(:user) }
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777",
          "university_id" => "9999999", "patron_group" => "staff", "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
      end
      let(:patron) do
        Requests::Patron.new(user: user, session: {}, patron: valid_patron)
      end

      before do
        allow(connection).to receive(:post).and_return(response)
      end

      it "responds with failure" do
        expect(clancy_item.request(patron: patron, hold_id: 'hold_id')).to be_falsey
        expect(clancy_item.errors).to eq(["Error connecting with Clancy: 403"])
      end
    end
  end

  context 'blank barcode' do
    let(:response) { "" }
    let(:clancy_item) { described_class.new(barcode: "", connection: connection) }

    describe '#status' do
      it "is has the status json" do
        expect(clancy_item.status["success"]).to be_falsey
        expect(clancy_item.errors).to be_empty
      end
    end

    describe '#not_at_clancy?' do
      it "is not_at_clancy" do
        expect(clancy_item.not_at_clancy?).to be_truthy
      end
    end

    describe '#available?' do
      it "is not available" do
        expect(clancy_item.available?).to be_falsey
      end
    end
  end
end
