# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::ClancyEdd, requests: true do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          alma_managed?: true,
          held_at_marquand_library?: true,
          item_at_clancy?: true,
          clancy_available?: true,
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          annex?: false,
          recap?: false,
          recap_pf?: false
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the clancy item is not available' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          clancy_available?: false,
          alma_managed?: true,
          held_at_marquand_library?: true,
          item_at_clancy?: true,
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          annex?: false,
          recap?: false,
          recap_pf?: false
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end
  end
end
