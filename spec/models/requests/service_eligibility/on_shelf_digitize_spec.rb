# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::OnShelfDigitize, requests: true do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          alma_managed?: true,
          annex?: false,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )

      user = FactoryBot.create(:valid_princeton_patron)
      allow(Bibdata).to receive(:get_patron).and_return(Requests::Patron.new(user:, patron_hash: { patron_group: "P" }))
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns true even if the item is in the annex' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          alma_managed?: true,
          on_order?: false,
          annex?: true,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )
      user = FactoryBot.create(:valid_princeton_patron)
      allow(Bibdata).to receive(:get_patron).and_return(Requests::Patron.new(user:, patron_hash: { patron_group: "P" }))
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns true for a user with patron group REG' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          alma_managed?: true,
          annex?: false,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )
      user = FactoryBot.create(:valid_princeton_patron)
      allow(Bibdata).to receive(:get_patron).and_return(Requests::Patron.new(user:, patron_hash: { patron_group: "REG" }))
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false for a user with patron group Affiliate' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false,
          on_order?: false,
          alma_managed?: true,
          annex?: false,
          recap?: false,
          recap_pf?: false,
          held_at_marquand_library?: false
        )
      user = FactoryBot.create(:valid_princeton_patron)
      allow(Bibdata).to receive(:get_patron).and_return(Requests::Patron.new(user:, patron_hash: { patron_group: "Affiliate" }))
      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
