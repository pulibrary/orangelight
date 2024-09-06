# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::ILL do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          alma_managed?: true,
          aeon?: false,
          online?: false,
          charged?: true
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user), any_loanable: false)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if it is an aeon resource' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: true,
          alma_managed?: true,
          online?: false,
          charged?: true
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user), any_loanable: false)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
