# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::ILL, requests: true do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'P' }) }
  let(:eligibility) { described_class.new(requestable:, patron:, any_loanable: false) }
  let(:requestable) { instance_double(Requests::Requestable) }
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      allow(requestable).to receive_messages(
          alma_managed?: true,
          aeon?: false,
          charged?: true,
          marquand_item?: false,
          item_at_clancy?: false
        )

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if it is an aeon resource' do
      allow(requestable).to receive_messages(
          aeon?: true,
          alma_managed?: true,
          charged?: true,
          marquand_item?: false
        )

      expect(eligibility.eligible?).to be(false)
    end

    context 'with an ineligible patron' do
      let(:patron) { Requests::Patron.new(user:, patron_hash: { patron_group: 'Affiliate-P' }) }

      it 'returns false if the patron is not in an eligible patron group' do
        allow(requestable).to receive_messages(
          alma_managed?: true,
          aeon?: false,
          charged?: true,
          marquand_item?: false,
          item_at_clancy?: false
        )

        expect(eligibility.eligible?).to be(false)
      end
    end

    context 'with a marquand item' do
      it 'returns false' do
        allow(requestable).to receive_messages(
            alma_managed?: true,
            aeon?: false,
            charged?: true,
            marquand_item?: true
          )

        expect(eligibility.eligible?).to be(false)
      end
    end
  end
end
