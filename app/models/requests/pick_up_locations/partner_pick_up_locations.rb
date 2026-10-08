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
        delegate :item, :location, to: :requestable

        # :reek:DuplicateMethodCall
        def partner_pickup_locations
          return default_pick_ups unless delivery_locations&.any?
          if collection_code == 'FL' || (collection_code == 'AR' && use_statement.present?)
            # FL (Harvard) can only be requested to marquand
            # AR (Columbia) can only be requested to marquand when there are item restrictions in use_statement
            [bibdata_delivery_locations[:PJ]]
          elsif collection_code == 'MR'
            # MR can only be requested to Mendel
            [bibdata_delivery_locations[:PK]]
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
    end
  end
end
