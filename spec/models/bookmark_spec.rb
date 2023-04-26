# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmark do
  it('cannot create a bookmark with an invalid user id') do
    bookmark1 = Bookmark.new user_id: -1, document_id: 123
    expect { bookmark1.save }.to raise_error(ActiveRecord::InvalidForeignKey)
  end

  describe 'removing bookmarks with deleted solr records' do
    let(:in_solr_alma_id_one) { '994956003506421' }
    let(:in_solr_alma_id_two) { '99118600973506421' }
    let(:in_solr_voyager_id) { '8908514' }
    let(:not_in_solr_alma_id) { '991234567806421' }
    let(:not_in_solr_voyager_id) { '1234567' }
    let!(:bookmark_one) { FactoryBot.create(:bookmark, document_id: document_ids[0]) }
    let!(:bookmark_two) { FactoryBot.create(:bookmark, document_id: document_ids[1]) }

    context 'with existing alma ids' do
      let(:document_ids) { [in_solr_alma_id_one, in_solr_alma_id_two] }

      it 'does not delete bookmarks with solr documents' do
        expect do
          Bookmark.destroy_without_solr_documents
        end.not_to change { Bookmark.count }
      end
    end

    context 'with existing and not existing alma ids' do
      let(:document_ids) { [in_solr_alma_id_one, not_in_solr_alma_id] }

      it 'deletes bookmarks without solr documents' do
        expect do
          Bookmark.destroy_without_solr_documents
        end.to change { Bookmark.count }.by(-1)
      end
    end

    context 'with more than one bookmark with the same alma id not in solr' do
      let(:document_ids) { [not_in_solr_alma_id, not_in_solr_alma_id] }

      it 'deletes bookmarks without solr documents' do
        expect do
          Bookmark.destroy_without_solr_documents
        end.to change { Bookmark.count }.by(-2)
      end
    end

    context 'with a voyager id that is in solr' do
      let(:document_ids) { [in_solr_alma_id_one, in_solr_voyager_id] }

      it 'does not delete the voyager bookmark' do
        expect do
          Bookmark.destroy_without_solr_documents
        end.not_to change { Bookmark.count }
      end
    end

    context 'with a voyager id that is not in solr' do
      let(:document_ids) { [in_solr_voyager_id, not_in_solr_voyager_id] }

      xit 'deletes the voyager bookmark that is not in solr' do
        expect do
          Bookmark.destroy_without_solr_documents
        end.to change { Bookmark.count }.by(-1)
      end
    end
  end
end
