# frozen_string_literal: true

class BookmarkButtonComponent < Blacklight::Document::BookmarkComponent
  def initialize(**kwargs)
    if Orangelight.using_blacklight7?
      super(**kwargs.except(:action))
    else
      super
    end
  end
end
