# frozen_string_literal: true

module BookmarksHelper
  def bookmarks?
    params[:controller] == 'bookmarks'
  end

  def sort_by_most_recently_bookmarked(documents, user)
    update_blank_sort_param
    if params[:sort] == 'score desc' && bookmarks?
      user.bookmarks.order(updated_at: :desc)
          .collect { |bookmark| bookmark.document_id.to_s }
          .filter_map { |id| documents.index_by(&:id)[id] }
    else
      documents
    end
  end

  private

    def update_blank_sort_param
      return if params[:sort].present?
      # make sure the recently bookmarked sort doesn't get used as the default and
      # force the recently bookmarked sort when viewing bookmarks without a sort param
      params[:sort] = bookmarks? ? 'score desc' : 'score desc, pub_date_start_sort desc, title_sort asc'
    end
end
