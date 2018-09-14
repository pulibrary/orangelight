# frozen_string_literal: true

class Orangelight::CallNumber < ApplicationRecord
  def self.table_name_prefix
    'orangelight_'
  end

  # Sorts an Array of CallNumber instances using their label dates
  # @param [Array<Orangelight::CallNumber>] call_numbers
  # @return [Array<Orangelight::CallNumber>] the (re)sorted Array
  def self.sort_by_label_date(call_numbers)
    sorted = []

    call_numbers.each_slice(2) do |a, b|
      if b.nil?
        sorted << a
      elsif a.label_date && b.label_date && ((a.label_date <=> b.label_date) == 1)
        sorted << b
        sorted << a
      else
        sorted << a
        sorted << b
      end
    end

    sorted
  end

  # Constructs a Date by parsing the label
  # @return [Date]
  def label_date
    m = / (\d{4})(?!\d)/.match(label)
    return unless m&.captures&.length == 1

    values = m.captures
    value = Date.parse("#{values.last}-01-01")
    value
  end

  # Compares two CallNumber instances
  # @see Object#<=>
  # @param [Orangelight::CallNumber] other
  # @return [Integer]
  def <=>(other)
    return 1 unless other.is_a?(self.class)
    sort <=> other.sort
  end
end
