# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::OnShelfPickup, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'P' }) }
  let(:eligibility) { described_class.new(requestable:, patron:) }
  let(:requestable) { instance_double(Requests::Requestable) }

  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      allow(requestable).to receive_messages(
          aeon?: false,
          alma_managed?: true,
          charged?: false,
          in_process?: false,
          circulates?: true,
          on_order?: false,
          annex?: false,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the item is in the annex' do
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          alma_managed?: true,
          in_process?: false,
          circulates?: true,
          on_order?: false,
          annex?: true,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )

      expect(eligibility.eligible?).to be(false)
    end
  end
end
