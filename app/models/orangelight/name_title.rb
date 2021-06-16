# frozen_string_literal: true

class Orangelight::NameTitle < ApplicationRecord
  def self.table_name_prefix
    "#{BrowseLists.table_prefix}_"
  end
end
