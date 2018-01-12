# frozen_string_literal: true

class Orangelight::CallNumber < ApplicationRecord
  def self.table_name_prefix
    'orangelight_'
  end
end
