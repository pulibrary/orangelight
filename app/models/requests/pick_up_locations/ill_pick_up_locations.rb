# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a resource that Princeton will request on their
    # behalf from another library via ILLiad
    class ILLPickUpLocations
      def initialize(form:, requestable:, bibdata_service_class: BibdataService)
        @form = form
        @requestable = requestable
        @bibdata_service_class = bibdata_service_class
      end

      def call
        code = delivery_location_code

        location = all_delivery_locations_minus_plasma_pa.find do |location|
          location["gfa_pickup"] == code
        end

        [location]
      end

      private

        attr_reader :bibdata_service_class, :form, :requestable

        delegate :illiad_account, to: :form

        # :reek:FeatureEnvy
        def all_delivery_locations_minus_plasma_pa
          all_delivery_locations.reject { |location| location["label"] == "Plasma Physics Library" && location["gfa_pickup"] == "PA" }
        end

        def all_delivery_locations
          @all_delivery_locations ||= bibdata_service_class.delivery_locations
        end

        def delivery_location_code
          return default_code unless illiad_account
          case illiad_account[:Site]
          in 'Architecture'
            'PW'
          in 'East Asian'
            'PL'
          in 'Engineering'
            'PT'
          in 'Music'
            'PK'
          in 'Stokes'
            'PM'
          else
            default_code
          end
        end

        def default_code
          # default to PA: Firestone
          'PA'
        end
    end
  end
end
