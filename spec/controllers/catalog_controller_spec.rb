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
    it 'supports a user-submitted note line' do
      sign_in user

      post :email, params: { id: '9741216', to: 'test@test.com', note: ['Subject'] }
      expect(email.note).to eq 'Subject'
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

  describe 'rendering facet values and links' do
    context 'when the display information cannot be retrieved for the facet' do
      it 'renders an error message' do
        expect do
          get :facet, params: { id: 'publication_place_facet_nonexistent', f: { 'format' => ['Audio'] }, '++++f' => { 'lc_1letter_facet' => ['M+-+Music'] } }
        end.to raise_error(ActionController::RoutingError, 'Not Found')
      end
    end
  end
end
