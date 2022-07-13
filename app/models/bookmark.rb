# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user, polymorphic: true
  validate :not_too_many_bookmarks

  def not_too_many_bookmarks
    return if user.bookmarks.count < Orangelight.config['bookmarks']['maximum']

    errors.add(:user, "You have exceeded the maximum number of bookmarks! You can only save up to #{Orangelight.config['bookmarks']['maximum']} bookmarks")
  end
end
