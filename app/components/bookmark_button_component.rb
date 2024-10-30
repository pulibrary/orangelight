# frozen_string_literal: true

class BookmarkButtonComponent < Blacklight::Document::BookmarkComponent
  def initialize(**kwargs)
    if using_blacklight7?
      super(**kwargs.except(:action))
    else
      super
    end
  end

  def using_blacklight7?
    @using_blacklight7 ||= Gem.loaded_specs['blacklight'].version.to_s.start_with? '7'
  end
end
