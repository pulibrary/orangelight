# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
  describe "#show" do
    context "when given a Voyager ID, where only Alma is indexed" do
      it "redirects to the Alma ID" do
        get :show, params: { id: "10647164" }

        expect(response).to redirect_to "/catalog/99106471643506421"
      end
    end
  end
  describe '#email' do
    let(:email) { ActionMailer::Base.deliveries[0] }
    let(:user) { FactoryBot.create(:user) }

    before do
      ActionMailer::Base.deliveries.clear
    end
    it 'sends reply-to when logged in as a CAS user' do
      sign_in user

      post :email, params: { id: '9741216', to: 'test@test.com' }

      expect(email.reply_to).to eq [user.email]
    end
    it 'supports a user-submitted subject line' do
      sign_in user

      post :email, params: { id: '9741216', to: 'test@test.com', subject: ['Subject'] }
      expect(email.subject).to eq 'Subject'
    end
    it 'does not send an email if not logged in' do
      post :email, params: { id: '9741216', to: 'test@test.com' }

      expect(email).to be_nil
    end
  end
  describe '#online_holding_note?' do
    subject(:note) { described_class.new.online_holding_note?(nil, document) }

    let(:link) { 'field not blank' }
    let(:holdings) do
      '{"1":{"location_has":["blah"]}}'
    end

    describe 'for document with link and holding note' do
      let(:document) { { electronic_access_1display: link, holdings_1display: holdings } }

      it 'returns true' do
        expect(note).to be true
      end
    end
    describe 'document with link missing holding note' do
      let(:document) { { electronic_access_1display: link } }

      it 'returns false' do
        expect(note).to be false
      end
    end
    describe 'document missing link with holding note' do
      let(:document) { { holdings_1display: holdings } }

      it 'returns false' do
        expect(note).to be false
      end
    end
  end
  describe 'session tracking' do
    it 'does not error if the session is invalid' do
      post :track, params: { id: '8938641', counter: 2, search_id: 123 }
      expect(response).to redirect_to(solr_document_path('8938641'))
    end
  end
  describe 'excessive paging' do
    it 'does not error when paging is reasonable' do
      get :index, params: { q: 'asdf', page: 2 }
      expect(response.status).to eq(200)
    end
    it 'errors when paging is excessive' do
      get :index, params: { q: 'asdf', page: 1500 }
      expect(response.status).to eq(400)
    end
  end

  describe 'home page' do
    let(:solr_empty_query) { File.open(fixture_path + '/solr_empty_query.json').read }

    before do
      allow(Rails.cache).to receive(:fetch).and_return solr_empty_query
    end

    it 'uses the cache for an empty search' do
      get :index, params: {}
      expect(response.status).to eq 200
      expect(Rails.cache).to have_received(:fetch)
    end

    it 'does not use the cache for a search with arguments' do
      get :index, params: { q: "coffee" }
      expect(response.status).to eq 200
      expect(Rails.cache).not_to have_received(:fetch)
    end
  end
end
