# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::InLibrary, requests: true do
  let(:user) { FactoryBot.create(:user) }
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        scsb_in_library_use?: true,
        item: { collection_code: "not_MR" },
        circulates?: false,
        recap_edd?: true,
        recap_pf?: true
      )
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        scsb_in_library_use?: true,
        item: { collection_code: "MR" },
        circulates?: false,
        recap_edd?: true,
        recap_pf?: false
      )
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
