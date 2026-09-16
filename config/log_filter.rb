# frozen_string_literal: true
# This class is responsible for filtering out payloads that we don't want to write to the logs
class LogFilter
  def self.call(event)
    visit event.payload if event.payload

    # We must return the literal boolean `true` in order to send this event to the logs
    true
  end

  SIMPLE_JSON_TYPES = [Numeric, String, Array, Hash].freeze

  def self.visit(node)
    if node.is_a? Hash
      node.keep_if { |_key, value| simple_json_type? value }
      node.each_value { visit it }
    elsif node.is_a? Array
      node.keep_if { simple_json_type? it }
      node.each { visit it }
    end
  end

  def self.simple_json_type?(node) = SIMPLE_JSON_TYPES.any? { |type| node.is_a? type }
end
