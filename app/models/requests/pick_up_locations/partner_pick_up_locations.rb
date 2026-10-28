# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a resource owned by a Recap Partner (e.g. NYPL, Columbia, Harvard)
    class PartnerPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        if partner_pickup_locations.empty?
          default_pick_ups[0]
        else
          partner_pickup_locations
        end
      end

      private

        attr_reader :form, :requestable

        delegate :default_pick_ups, to: :form
        delegate :item, :location, :patron, to: :requestable
        # :reek:TooManyStatements
        # :reek:DuplicateMethodCall
        def partner_pickup_locations
          return default_pick_ups unless delivery_locations&.any?
          if collection_code == 'FL' || (collection_code == 'AR' && use_statement.present?)
            # FL (Harvard) can only be requested to marquand
            # AR (Columbia) can only be requested to marquand when there are item restrictions in use_statement
            [bibdata_delivery_location("PJ")].compact
          elsif collection_code == 'MR'
            # MR can only be requested to Mendel
            [bibdata_delivery_location("PK")].compact
          elsif eligible_pickup_from_pppl?
            # Faculty patrons in the PPPL statistic category can pick up from Firestone and Plasma Physics
            # unrestricted items
            delivery_locations + [default_pick_ups.find { |location| location[:gfa_pickup] == "PQ" }]
          else
            delivery_locations
          end
        end

        def collection_code
          @collection_code ||= item[:collection_code]
        end

        def use_statement
          @use_statement ||= item[:use_statement].to_s
        end

        def delivery_locations
          location[:delivery_locations]
        end

        def bibdata_delivery_locations
          @bibdata_delivery_locations ||= Requests::BibdataService.delivery_locations
        end

        # :reek:FeatureEnvy
        def bibdata_delivery_location(gfa_pickup)
          location = bibdata_delivery_locations.find { |delivery_location| delivery_location["gfa_pickup"] == gfa_pickup }
          return unless location

          location.merge("pick_up_location_code" => location.dig("library", "code"))
        end

        def eligible_pickup_from_pppl?
          patron.eligible_pickup_from_pppl?
        end
    end
  end
end
