# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::OnShelfDigitize do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          annex?: false,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(true)
    end
  end
end
