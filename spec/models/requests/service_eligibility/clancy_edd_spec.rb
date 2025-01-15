# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::ClancyEdd, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'P' }) }
  let(:eligibility) { described_class.new(requestable:, patron:) }
  let(:requestable) { instance_double(Requests::Requestable) }

  describe '#eligible?' do
    it 'returns true if all criteria are met' do
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

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the clancy item is not available' do
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

      expect(eligibility.eligible?).to be(false)
    end
    context 'with an ineligible patron' do
      let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'Affiliate-P' }) }

      it 'returns false if the patron is not in an eligible patron group' do
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

        expect(eligibility.eligible?).to be(false)
      end
    end
  end
end
