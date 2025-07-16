# frozen_string_literal: true
# This component is responsible for rendering a holding's availability
# (which will be provided by Javascript based on the DOM structure of
# this component)
class Holdings::HoldingAvailabilityComponent < ViewComponent::Base
  def initialize(doc_id, holding_id, location_rules, temp_location_code)
    @doc_id = doc_id
    @holding_id = holding_id
    @location_rules = location_rules
    @temp_location_code = temp_location_code
  end

    private

      attr_reader :doc_id, :holding_id, :temp_location_code

      def aeon_location?
        location_rules[:aeon_location]
      end

      def location_rules
        @location_rules || {}
      end
end
