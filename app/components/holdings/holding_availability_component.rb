# frozen_string_literal: true
# This component is responsible for rendering a holding's availability
# (which will be provided by Javascript based on the DOM structure of
# this component)
# :reek:TooManyInstanceVariables
class Holdings::HoldingAvailabilityComponent < ViewComponent::Base
  def initialize(doc_id, holding_id, holding, location_rules, temp_location_code)
    @doc_id = doc_id
    @holding_id = holding_id
    @holding = holding
    @location_rules = location_rules
    @temp_location_code = temp_location_code
  end

    private

      attr_reader :holding_id, :temp_location_code

      def aeon_location?
        location_rules[:aeon_location]
      end

      def doc_id
        @holding['source_id'] || @doc_id
      end

      def location_rules
        @location_rules || {}
      end
end
