# frozen_string_literal: true
# This component is responsible for displaying location information about
# a holding on the search results page
class Holdings::SearchLocationComponent < ViewComponent::Base
  def initialize(holding_hash)
    @holding_hash = holding_hash
  end

    private

      def location
        helpers.holding_library_label(holding_hash)
      end

      def call_number
        CallNumber.new(holding_hash['call_number']).with_line_break_suggestions
      end

      attr_reader :holding_hash
end
