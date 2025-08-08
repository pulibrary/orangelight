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
        return library_in_use if library_in_use
        helpers.holding_library_label(holding_hash)
      end

      def library_in_use
        location_code = holding_hash['location_code']
        library_in_use_locations = {
          'arch$pw': "Archictecture (Remote Storage)",
          'eastasian$pl': "East Asian (Remote Storage)",
          'engineer$pt': "Engineering (Remote Storage)",
          'firestone$pb': "Firestone (Remote Storage)",
          'firestone$pf': "Firestone (Remote Storage)",
          'lewis$pn': "Lewis (Remote Storage)",
          'lewis$ps': "Lewis (Remote Storage)",
          'mendel$pk': "Mendel (Remote Storage)",
          'stokes$pm': "Stokes (Remote Storage)"
        }.freeze
        library_in_use_locations[location_code.to_sym]
      end

      def call_number
        CallNumber.new(holding_hash['call_number']).with_line_break_suggestions
      end
end
