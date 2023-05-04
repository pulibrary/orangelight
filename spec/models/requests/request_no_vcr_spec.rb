# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Request, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user:, session: {}, patron: valid_patron)
  end
  context "with an object with a LOT of items" do
    let(:document_id) { '9933643713506421' }
    let(:params) do
      {
        system_id: document_id,
        mfhd: '22727480400006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    let(:catalog_raw_fixture) { Rails.root.join('spec', 'fixtures', 'raw', "#{document_id}_raw.json") }

    before do
      stub_request(:get, "https://catalog.princeton.edu/catalog/#{document_id}/raw")
        .to_return(status: 200, body: catalog_raw_fixture)
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/eastasian$cjk.json")
        .to_return(status: 200, body: fixture('/bibdata/eastasian_cjk_holding_locations.json'))
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/#{params[:system_id]}/holdings/#{params[:mfhd]}/availability.json").to_timeout
      stub_delivery_locations
    end

    describe "#requestable" do
      it "does not list items so that it does not time out" do
        expect(request.requestable).to be_truthy
        expect(request.requestable.size).to eq(1)
        expect(request.requestable[0].item?).to be_falsey
      end
    end
  end
end
