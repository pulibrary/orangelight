# frozen_string_literal: true

module BookmarksHelper
  def bookmarks?
    params[:controller] == 'bookmarks'
  end

  def sort_by_most_recently_bookmarked(documents, user)
    if params[:sort].blank? && bookmarks?
      # force the recently bookmarked sort when viewing bookmarks without a sort param
      params[:sort] = 'score desc'
    elsif params[:sort].blank? && !bookmarks?
      # make sure the recently bookmarked sort doesn't get used as the default
      params[:sort] = 'score desc, pub_date_start_sort desc, title_sort asc'
    end
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
