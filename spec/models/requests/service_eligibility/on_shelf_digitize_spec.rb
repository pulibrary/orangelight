# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::OnShelfDigitize, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'P' }) }
  let(:eligibility) { described_class.new(requestable:, user: FactoryBot.create(:user), patron:) }
  let(:requestable) { instance_double(Requests::Requestable) }

  describe '#eligible?' do
    it 'returns true if all criteria are met' do
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

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns true even if the item is in the annex' do
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

      expect(eligibility.eligible?).to be(true)
    end
    context 'with a staff user' do
      let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'REG' }) }

      it 'returns true for a user with patron group REG' do
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

        expect(eligibility.eligible?).to be(true)
      end
    end

    context 'with an Affiliate user' do
      let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'Affiliate' }) }
      it 'returns false for a user with patron group Affiliate' do
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

        expect(eligibility.eligible?).to be(false)
      end
    end
  end
end
