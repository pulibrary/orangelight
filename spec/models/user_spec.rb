# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User do
  context "when there are guest users older than 7 days" do
    before do
      # There's an initial user that we don't want
      described_class.all.find_each(&:destroy)
      Timecop.freeze(Time.now.utc - 10.days) do
        100.times do
          FactoryBot.create(:guest_patron, guest: true)
        end
        10.times do
          FactoryBot.create(:valid_princeton_patron)
        end
      end
      10.times do
        FactoryBot.create(:guest_patron)
      end
    end

    it "expires them" do
      expect { described_class.expire_guest_accounts }.to change { described_class.count }.by(-100)
    end
  end

  describe ".from_cas" do
    it "finds the user in the database" do
      access_token = OmniAuth::AuthHash.new(provider: "provider", uid: "1234")
      described_class.from_cas(access_token)
      expect(User.last.provider).to eq("provider")
      expect(User.last.uid).to eq("1234")
    end
  end
end
