# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::Pickup, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_patron) { { "netid" => "foo", "patron_group" => "P" }.with_indifferent_access }
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        recap_pf?: false,
        holding_library_in_library_only?: false,
        circulates?: true,
        eligible_for_library_services?: true,
        item_data?: true,
        scsb_in_library_use?: false,
        charged?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        recap_pf?: false,
        holding_library_in_library_only?: true,
        circulates?: false,
        eligible_for_library_services?: false,
        item_data?: true,
        charged?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end

    it 'returns false if the item is charged' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        charged?: true,
        recap?: true,
        recap_pf?: false,
        holding_library_in_library_only?: false,
        circulates?: true,
        eligible_for_library_services?: true,
        item_data?: true,
        scsb_in_library_use?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
