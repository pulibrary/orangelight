# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::Digitize, requests: true do
  describe '#eligible?' do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_patron) { { "netid" => "foo", "patron_group" => "P" }.with_indifferent_access }
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        recap_pf?: false,
        recap_edd?: true,
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
        recap_edd?: false,
        charged?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end

    it 'returns false if the requestable is charged' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        charged?: true,
        recap?: true,
        recap_pf?: false,
        recap_edd?: true,
        item_data?: true,
        scsb_in_library_use?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
