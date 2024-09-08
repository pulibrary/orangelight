# frozen_string_literal: true

class Orangelight::Subject < ApplicationRecord
  def self.table_name_prefix
    "alma_orangelight_"
  end
end
