module BookmarksHelper
  def bookmarks?
    params[:controller] == 'bookmarks'
  end
end
