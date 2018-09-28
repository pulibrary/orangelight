# frozen_string_literal: true

class Orangelight::CallNumber < ApplicationRecord
  def self.table_name_prefix
    'orangelight_'
  end

  # Compares two CallNumber instances
  # @see Object#<=>
  # @param [Orangelight::CallNumber] other
  # @return [Integer]
  def <=>(other)
    return 1 unless other.is_a?(self.class)
    return label <=> other.label if sort.nil? && other.nil?

    sort <=> other.sort
  end
end
