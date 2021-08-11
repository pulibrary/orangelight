# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DBMigrateUppercaseUsernames do
  let(:username) { "testUSER123" }
  let!(:uppercase_user) { FactoryBot.create(:user, username: username) }
  let!(:lowercase_user) { FactoryBot.create(:user, username: username.downcase) }
  let(:migrator) { described_class.new }

  describe ".find_uppercase_users" do
    it "finds users with uppercase letters in their usernames" do
      expect(migrator.find_uppercase_users).to eq([uppercase_user])
    end
  end

  describe ".find_lowercase_user" do
    it "finds user with lowercase equivalent of uppercase username" do
      expect(migrator.find_lowercase_user(uppercase_user)).to eq(lowercase_user)
    end
  end

  describe ".merge_bookmarks" do
    it "transfer bookmarks to user with lowercase username" do
      uppercase_user.bookmarks.create!([{ document_id: '9741216', document_type: 'SolrDocument' }])
      expect { migrator.merge_bookmarks(uppercase_user, lowercase_user) }.to change(lowercase_user.bookmarks, :count).by(1)
    end
  end

  describe ".merge_searches" do
    it "merge searches" do
      uppercase_user.searches.create!([{ query_params: 'history' }])
      expect { migrator.merge_searches(uppercase_user, lowercase_user) }.to change(lowercase_user.searches, :count).by(1)
    end
  end

  describe ".delete_uppercase_user" do
    it "deletes users with uppercase letters in their usernames" do
      expect { migrator.delete_uppercase_user(uppercase_user) }.to change(User, :count).by(-1)
    end
  end
end
