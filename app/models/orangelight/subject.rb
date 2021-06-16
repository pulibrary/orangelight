# frozen_string_literal: true

class Orangelight::Subject < ApplicationRecord
  def self.table_name_prefix
    "#{BrowseLists.table_prefix}_"
  end
end
