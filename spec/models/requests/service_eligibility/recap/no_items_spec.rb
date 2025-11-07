# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::NoItems, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_patron) { { "netid" => "foo", "patron_group" => "P" }.with_indifferent_access }
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        item_data?: false,
        recap?: true,
        recap_pf?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        item_data?: true,
        recap?: true,
        recap_pf?: false
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
