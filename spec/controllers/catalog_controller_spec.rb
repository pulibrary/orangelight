require 'rails_helper'

RSpec.describe CatalogController do
  describe '#email' do
    let(:email) { ActionMailer::Base.deliveries[0] }
    let(:user) { FactoryBot.create(:user) }

    before do
      ActionMailer::Base.deliveries.clear
    end
    it "doesn't send reply-to when not logged in" do
      post :email, params: { id: '9741216', to: 'test@test.com' }
      expect(email.reply_to).to eq []
    end
    it 'sends reply-to when logged in as a CAS user' do
      sign_in user

      post :email, params: { id: '9741216', to: 'test@test.com' }

      expect(email.reply_to).to eq [user.email]
    end
    it 'supports a user-submitted subject line' do
      post :email, params: { id: '9741216', to: 'test@test.com', subject: ['Subject'] }
      expect(email.subject).to eq 'Subject'
    end
  end

  describe 'GET #show' do
    context 'with an invalid document id' do
      let(:id) { 'notavalidid' }

      it 'returns a 404 response for an html request' do
        get :show, params: { id: id }
        expect(response.status).to eq 404
      end

      it 'returns a 404 response for an xml request' do
        get :show, format: :xml, params: { id: id }
        expect(response.status).to eq 404
      end
    end
  end
end
