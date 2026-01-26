# frozen_string_literal: true

module BookmarksHelper
  def bookmarks?
    params[:controller] == 'bookmarks'
  end

  def sort_by_most_recently_bookmarked(documents, user)
    if params[:sort] == 'score desc' && bookmarks?
      solr_docs = documents.index_by(&:id)
      user.bookmarks.order(updated_at: :desc)
          .collect { |bookmark| bookmark.document_id.to_s }
          .filter_map { |id| solr_docs[id] }
    else
      documents
    end
  end
end
