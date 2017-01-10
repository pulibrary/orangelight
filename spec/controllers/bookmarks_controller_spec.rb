require 'rails_helper'

RSpec.describe BookmarksController do
  describe '#print' do
    let(:user) { FactoryGirl.create(:user) }
    it 'renders the email record mailer' do
      sign_in user
      user.bookmarks.create!([{ document_id: '9741216', document_type: 'SolrDocument' }])
      get :print
      expect(assigns(:documents).length).to eq 1
      expect(response).to render_template 'record_mailer/email_record.text.erb'
    end
  end
end
