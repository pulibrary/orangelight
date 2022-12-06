# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :document, polymorphic: true
  validate :not_too_many_bookmarks, on: :create

  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    value = super if defined?(super)
    value &&= value.constantize
    value || default_document_type
  end

  def default_document_type
    SolrDocument
  end

  def not_too_many_bookmarks
    return if user.bookmarks.count < Orangelight.config['bookmarks']['maximum']

    errors.add(:user, "You have exceeded the maximum number of bookmarks! You can only save up to #{Orangelight.config['bookmarks']['maximum']} bookmarks")
  end
end
