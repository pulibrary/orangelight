# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
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

  describe 'hathi url api' do
    before do
      stub_hathi
    end

    context 'when the item has hathi data' do
      it 'returns the hathi_url' do
        hathi_url =
          "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=" \
          "https://idp.princeton.edu/idp/shibboleth" \
          "&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Duc1.c2754878"

        get :hathi, params: { id: '426420', format: :json }
        expect(response.status).to eq(200)
        expect(response.body).to eq(
          { hathi_url: hathi_url }.to_json
        )
      end
    end

    context 'when the item does not have hathi data' do
      it 'returns 404' do
        get :hathi, params: { id: '8938641', format: :json }
        expect(response.status).to eq(404)
        expect(response.body).to eq(
          { error: "not-found" }.to_json
        )
      end
    end
  end

  describe 'show does not include the hathi url' do
    before do
      stub_hathi
    end

    it 'sets the assign hathi_url for an item with hathi data' do
      get :show, params: { id: '426420' }
      expect(response.status).to eq(200)
      expect(assigns(:hathi_url)).not_to eq(
        "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=" \
        "https://idp.princeton.edu/idp/shibboleth" \
        "&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Duc1.c2754878"
      )
    end

    it 'sets the assign hathi_url it nil for an item without hathi data' do
      get :show, params: { id: '8938641' }
      expect(response.status).to eq(200)
      expect(assigns(:hathi_url)).to be_nil
    end

    it 'sets the assign hathi_url it nil for a SCSB item' do
      get :show, params: { id: 'SCSB-2443272' }
      expect(response.status).to eq(200)
      expect(assigns(:hathi_url)).to be_nil
    end
  end
end
