# frozen_string_literal: true

module BookmarksHelper
  def bookmarks?
    params[:controller] == 'bookmarks'
  end

  def sort_by_most_recently_bookmarked(documents, user)
    if params[:sort] == 'score desc' && bookmarks?
      bookmarks = user.bookmarks.order(updated_at: :desc)
      bookmark_ids = bookmarks.collect { |bookmark| bookmark.document_id.to_s }
      solr_docs = documents.map { |doc| [doc.id, doc] }.to_h
      bookmark_ids.map { |id| solr_docs[id] }.compact
    else
      documents
    end
  end
end
