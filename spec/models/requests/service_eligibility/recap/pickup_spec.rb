# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::Pickup, requests: true do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      user = FactoryBot.build(:valid_princeton_patron)
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        recap_pf?: false,
        holding_library_in_library_only?: false,
        circulates?: true,
        eligible_for_library_services?: true,
        item_data?: true,
        scsb_in_library_use?: false
      )
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      user = FactoryBot.build(:valid_princeton_patron)

      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        recap_pf?: false,
        holding_library_in_library_only?: true,
        circulates?: false,
        eligible_for_library_services?: false,
        item_data?: true
      )
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
