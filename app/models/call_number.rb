# frozen_string_literal: true

# This class is responsible for preparing a call number for display
class CallNumber
  def initialize(label)
    @label = label
  end

  def with_line_break_suggestions
    sanitize label.gsub('.', '<wbr>.')
  end

    private

      def label
        @label || ''
      end

      def sanitize(html)
        ActionController::Base.helpers.sanitize html, scrubber:
      end

      # :reek:FeatureEnvy
      def scrubber
        @scrubber ||= Loofah::Scrubber.new do |node|
          node.remove unless node.text? || node.name == 'wbr'
        end
      end
end
