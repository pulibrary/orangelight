# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :user, polymorphic: true
  validates_associated :user
end
