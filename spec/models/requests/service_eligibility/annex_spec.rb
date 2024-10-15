# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Annex, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'P' }) }
  let(:eligibility) { described_class.new(requestable:, user: FactoryBot.create(:user), patron:) }
  let(:requestable) { instance_double(Requests::Requestable) }

  describe '#eligible?' do
    it 'returns true if the item is in the annex' do
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          annex?: true,
          alma_managed?: true,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the item is not in the annex' do
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          annex?: false,
          alma_managed?: true,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )

      expect(eligibility.eligible?).to be(false)
    end
  end
end
