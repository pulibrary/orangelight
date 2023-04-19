# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User do
  describe '#expire_guest_accounts' do
    before do
      # There's an initial user that we don't want
      described_class.all.find_each(&:destroy)
    end
    context "when there are guest users older than 7 days" do
      before do
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

    context 'when a guest user older than 7 days has bookmarks' do
      let(:guest) { FactoryBot.create(:guest_patron, guest: true) }
      before do
        Timecop.freeze(Time.now.utc - 10.days) do
          (1..5).each do |document_id|
            bookmark = Bookmark.new
            bookmark.user = guest
            bookmark.document_id = document_id
            guest.bookmarks << bookmark
          end
          guest
        end
      end
      it 'deletes the bookmarks' do
        expect(guest.bookmarks.count).to eq(5)
        expect { described_class.expire_guest_accounts }.to change { Bookmark.count }.by(-5)
      end
    end
  end

  describe ".from_cas" do
    let(:access_token) { OmniAuth::AuthHash.new(provider: "provider", uid: "testUSER123") }

    it "finds or creates user in the database" do
      expect { described_class.from_cas(access_token) }.to change(described_class, :count).by(1)
    end

    it "downcases username" do
      described_class.from_cas(access_token)
      expect(described_class.last.username).to eq("testuser123")
    end
  end
  describe "admin users" do
    context "a regular user" do
      let(:user) { FactoryBot.create(:user) }
      it "recognizes that it is not an admin" do
        expect(user.guest?).to eq(false)
        expect(user.admin?).to eq(false)
      end
    end
    context "an unauthenticated user" do
      let(:user) { FactoryBot.create(:unauthenticated_patron) }
      it "recognizes that it is not an admin" do
        expect(user.guest?).to eq(true)
        expect(user.admin?).to eq(false)
      end
    end
    context "an admin user" do
      let(:user) { FactoryBot.create(:user) }
      around do |example|
        cached_admin_netids = ENV['ORANGELIGHT_ADMIN_NETIDS'] || ''
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids + " #{user.uid}"
        example.run
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids
      end
      it "recognizes that it is an admin" do
        expect(user.guest?).to eq(false)
        expect(user.admin?).to eq(true)
      end
    end
  end
end
