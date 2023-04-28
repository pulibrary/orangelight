# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :document, polymorphic: true

  # TODO: remove the following scope, since as of
  # migration 20230419231330, the database layer
  # will not allow bookmarks without a valid user
  scope :without_valid_user, -> { where('user_id NOT IN (SELECT id FROM users)') }

  def document_type
    SolrDocument
  end

  def self.destroy_without_solr_documents
    batch_size = Orangelight.config["bookmarks"]["batch_size"]
    Bookmark.find_in_batches(batch_size:).with_index do |bookmarks, batch|
      Rails.logger.info { "Processing destroy_without_solr_documents group ##{batch}" }
      bookmark_doc_ids = bookmark_doc_ids(bookmarks)
      doc_ids_without_solr_doc = bookmark_doc_ids - doc_ids_in_solr(bookmark_doc_ids)

      if doc_ids_without_solr_doc.present?
        doc_ids_without_solr_doc.each do |doc_id|
          Bookmark.where(document_id: doc_id)&.destroy_all
        end
      end
    end
  end

  def self.update_to_alma_ids
    Bookmark.where("LENGTH(document_id) <= 7").find_in_batches.with_index do |bookmarks, batch|
      Rails.logger.info { "Processing update_to_alma_ids group ##{batch}" }
      bookmarks.each do |bookmark|
        bookmark.document_id = bookmark.voyager_to_alma_id
        bookmark.save if bookmark.changed?
      end
    end
  end

  def self.bookmark_doc_ids(bookmarks)
    bookmarks.map(&:document_id).to_set
  end

  def self.doc_ids_in_solr(bookmark_doc_ids)
    solr = Blacklight.default_index.connection
    rows = Orangelight.config["bookmarks"]["batch_size"]
    response = solr.get 'select', params: { fq: "{!terms f=id}#{bookmark_doc_ids.join(',')}", fl: 'id', rows: }
    response["response"]["docs"].map { |doc| doc["id"] }
  end

  # This method duplicates logic in the SolrDocument, but it did not seem well-suited for
  # re-use directly here (needing to instantiate a SolrDocument for each ID before being able to call it)
  def voyager_to_alma_id
    return document_id if document_id.length > 7 && document_id.start_with?("99")
    "99#{document_id}3506421"
  end
end
