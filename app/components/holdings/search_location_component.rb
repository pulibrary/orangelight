# frozen_string_literal: true
# This component is responsible for displaying location information about
# a holding on the search results page
class Holdings::SearchLocationComponent < ViewComponent::Base
  def initialize(holding_hash)
    @holding_hash = holding_hash
  end

    private

      attr_reader :holding_hash

      def location
        in_library_use_label = InLibraryUse.new(holding_hash['location_code']).label
        return in_library_use_label if in_library_use_label
        helpers.holding_library_label(holding_hash)
      end

      def call_number
        CallNumber.new(holding_hash['call_number']).with_line_break_suggestions
      end
end
