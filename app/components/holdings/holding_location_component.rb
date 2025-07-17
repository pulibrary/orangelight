# frozen_string_literal: true

# This component is responsible for displaying the location where a
# holding can be found
class Holdings::HoldingLocationComponent < ViewComponent::Base
  def initialize(holding, location, holding_id, call_number)
    @holding = holding
    @location = location
    @holding_id = holding_id
    @call_number = call_number
  end

    private

      attr_reader :holding, :location, :holding_id, :call_number

      def render_stackmap?
        locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
        return false if locator.exclude?(call_number:, library:)
        helpers.find_it_location?(location_code)
      end

      def location_code
        holding['location_code']
      end

      def library
        holding['library']
      end
end
