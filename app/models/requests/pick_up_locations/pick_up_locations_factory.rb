# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for selecting the appropriate pickup locations for a
    # given form and requestable
    class PickUpLocationsFactory
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        locations_class.new(requestable:, form:).call
      end

      private

        attr_reader :form, :requestable

        delegate :annex?, :ill_eligible?, :location, :partner_holding?, :recap?, to: :requestable

        def locations_class
          if annex?
            AnnexPickUpLocations
          elsif ill_eligible?
            ILLPickUpLocations
          elsif partner_holding?
            PartnerPickUpLocations
          elsif non_standard_circ_location? && !recap?
            NonStandardCircLocationPickUpLocations
          else
            AlmaPickUpLocations
          end
        end

        def non_standard_circ_location?
          !location&.standard_circ_location?
        end
    end
  end
end
