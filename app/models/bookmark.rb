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
end
