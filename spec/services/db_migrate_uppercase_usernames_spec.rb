# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DBMigrateUppercaseUsernames do
  let(:username) { "testUSER123" }
  let!(:uppercase_user) { FactoryBot.create(:user, username: username) }

  describe "self.run" do
    context "when there is an equivalent lowercase user" do
      let!(:lowercase_user) { FactoryBot.create(:user, username: username.downcase) }

      it "merges bookmarks into existing user" do
        uppercase_user.bookmarks.create([{ document_id: '9741216', document_type: 'SolrDocument' }])
        expect { described_class.run }.to change(lowercase_user.bookmarks, :count).by(1)
      end

      it "doesn't merge bookmark into existing user if they already have it" do
        uppercase_user.bookmarks.create([{ document_id: '9741216', document_type: 'SolrDocument' }])
        lowercase_user.bookmarks.create([{ document_id: '9741216', document_type: 'SolrDocument' }])
        expect { described_class.run }.to change(lowercase_user.bookmarks, :count).by(0)
      end

      it "merges searches into existing user" do
        uppercase_user.searches.create([{ query_params: { q: 'history' } }])
        expect { described_class.run }.to change(lowercase_user.searches, :count).by(1)
      end

      it "doesn't merge search into existing user if they already have it" do
        uppercase_user.searches.create([{ query_params: { q: 'history' } }])
        lowercase_user.searches.create([{ query_params: { q: 'history' } }])
        expect { described_class.run }.to change(lowercase_user.searches, :count).by(0)
      end
    end

    context "when there is not an equivalent lowercase user" do
      it "creates a new lowercase user" do
        expect { described_class.run }.to change(User, :count).by(1)
      end

      it "merges bookmarks into new user" do
        uppercase_user.bookmarks.create([{ document_id: '9741216', document_type: 'SolrDocument' }])
        described_class.run
        expect(User.last.bookmarks.count).to eq(1)
      end

      it "merges searches into new user" do
        uppercase_user.searches.create([{ query_params: { q: 'history' } }])
        described_class.run
        expect(User.last.searches.count).to eq(1)
      end
    end
  end
end
