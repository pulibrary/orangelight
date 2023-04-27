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
    let(:not_in_solr_alma_id) { '991234567806421' }
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
  end

  describe 'converting all document_ids to alma ids' do
    let(:voyager_id_one) { '8908514' }
    let(:voyager_id_two) { '1234567' }
    let(:converted_voyager_id) { '9989085143506421' }
    let(:alma_id) { '99118600973506421' }
    let(:document_ids) { [voyager_id_one, voyager_id_two, alma_id] }
    let!(:bookmark_one) { FactoryBot.create(:bookmark, document_id: document_ids[0]) }
    let!(:bookmark_two) { FactoryBot.create(:bookmark, document_id: document_ids[1]) }
    let!(:bookmark_three) { FactoryBot.create(:bookmark, document_id: document_ids[2]) }

    it 'does not change Bookmarks with an alma document_id' do
      expect do
        Bookmark.update_to_alma_ids
      end.not_to change { bookmark_three.reload.document_id }
    end

    it 'updates bookmarks with a voyager document_id' do
      expect do
        Bookmark.update_to_alma_ids
      end.to change { bookmark_one.reload.document_id }
    end
  end
end
