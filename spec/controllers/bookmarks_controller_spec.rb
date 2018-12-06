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
    let(:headers) { 'ID,Title,Title (Original Script),Author,Author (Original Script),Format,Language,Published/Created,Date,Description,Series,Location,Call Number,Notes' }

    let(:data1) { ['9741216', 'Adriaen van de Velde : Dutch master of landscape', 'Cornelis, Bart', 'Book', 'English', 'London: Paul Holberton Publishing', '2016', '224 pages : illustrations (some color) ; 29 cm', 'Marquand Library', 'ND653.V414 A4 2016', 'Published to accompany the exhibition held at the Rijksmuseum, Amsterdam, 24 June - 15 September 2016 and Dulwich Picture Gallery, London, 12 October 2016 - 15 January 2017.'] }
    let(:data2) { ['3148879', 'Sin, Chae-hong', '신재홍', "Tongnipkun u\u0306i cho\u0306nt'u", '독립군의전투　/'] }
    let(:bad_value) { 'Adriaen van de Velde : Dutch master of landscape / Bart Cornelis, Marijn Schapelhouman' }

    it 'renders a CSV list of metadata' do
      sign_in user
      user.bookmarks.create!([{ document_id: '9741216', document_type: 'SolrDocument' }])
      user.bookmarks.create!([{ document_id: '3148879', document_type: 'SolrDocument' }])
      get :csv

      body = response.body.force_encoding('UTF-8')

      expect(assigns(:documents).length).to eq 2
      expect(body).to include(headers)
      data1.each do |value|
        expect(body).to include(value)
      end
      data2.each do |value|
        expect(body).to include(value)
      end

      expect(body).not_to include(bad_value)
    end
  end
end
