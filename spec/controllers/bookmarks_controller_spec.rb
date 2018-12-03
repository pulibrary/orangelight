# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController do
  describe '#print' do
    let(:user) { FactoryBot.create(:user) }

    it 'renders the email record mailer' do
      sign_in user
      user.bookmarks.create!([{ document_id: '9741216', document_type: 'SolrDocument' }])
      get :print
      expect(assigns(:documents).length).to eq 1
      expect(response).to render_template 'record_mailer/email_record.text.erb'
    end
  end

  describe '#csv' do
    let(:user) { FactoryBot.create(:user) }
    let(:headers) { 'ID,Title,Author,Format,Language,Published/Created,Date,Description,Series,Location,Call Number,Notes' }
    let(:data) { ['9741216', 'Adriaen van de Velde : Dutch master of landscape', 'Cornelis, Bart', 'Book', 'English', 'London: Paul Holberton Publishing', '2016', '224 pages : illustrations (some color) ; 29 cm', 'Marquand Library', 'ND653.V414 A4 2016', 'Published to accompany the exhibition held at the Rijksmuseum, Amsterdam, 24 June - 15 September 2016 and Dulwich Picture Gallery, London, 12 October 2016 - 15 January 2017.'] }

    it 'renders a CSV list of metadata' do
      sign_in user
      user.bookmarks.create!([{ document_id: '9741216', document_type: 'SolrDocument' }])
      get :csv
      expect(assigns(:documents).length).to eq 1
      expect(response.body).to include(headers)
      data.each do |value|
        expect(response.body).to include(value)
      end
    end
  end
end
