# frozen_string_literal: true
# This component is responsible for showing the user
# which services are available for a holding, given
# its location (typically some type of Request button)
# :reek:TooManyMethods
class Holdings::LocationServicesComponent < ViewComponent::Base
  def initialize(adapter, holding_id, location_rules, holding)
    @adapter = adapter
    @holding_id = holding_id
    @location_rules = location_rules
    @holding = holding
  end

    private

      attr_reader :adapter, :holding_id, :location_rules, :holding

      def doc_id
        holding["mms_id"] || adapter.doc_id
      end

      def holding_object
        Requests::Holding.new(mfhd_id: holding_id, holding_data: holding)
      end

      # rubocop:disable Lint/DuplicateBranch
      # :reek:TooManyStatements
      def button_component
        if holding_id == 'thesis' || numismatics?
          AeonRequestButtonComponent.new(document:, holding: holding_hash, url_class: Requests::NonAlmaAeonUrl)
        elsif items && items.length > 1
          RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
        elsif aeon_location?
          AeonRequestButtonComponent.new(document:, holding: holding_hash)
        elsif scsb_location?
          RequestButtonComponent.new(doc_id:, location: location_rules, holding:)
        elsif temporary_holding_id?
          holding_identifier = temporary_location_holding_id_first
          RequestButtonComponent.new(doc_id:, holding_id: holding_identifier, location: location_rules)
        else
          RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
        end
      end
      # rubocop:enable Lint/DuplicateBranch

      def show_request
        if (requestable? && !thesis?) || numismatics?
          'service-always-requestable'
        else
          'service-conditional'
        end
      end

      def requestable?
        !adapter.alma_holding?(holding_id) || aeon_location? || scsb_location?
      end

      def open_location?
        location_rules && location_rules[:open]
      end

      def aeon_location?
        location_rules && location_rules[:aeon_location]
      end

      def requestable_location?
        return false if adapter.sc_location_with_suppressed_button?(holding)
        return false if adapter.unavailable_holding?(holding)
        location_rules && location_rules[:requestable]
      end

      def numismatics?
        holding_id == 'numismatics'
      end

      def thesis?
        holding_id == 'thesis' && adapter.pub_date > 2012
      end

      def scsb_location?
        location_rules && /^scsb.+/ =~ location_rules['code']
      end

      # Example of a temporary holding, in this case holding_id is : firestone$res3hr
      # {\"firestone$res3hr\":{\"location_code\":\"firestone$res3hr\",
      # \"current_location\":\"Circulation Desk (3 Hour Reserve)\",\"current_library\":\"Firestone Library\",
      # \"call_number\":\"HT1077 .M87\",\"call_number_browse\":\"HT1077 .M87\",
      # \"items\":[{\"holding_id\":\"22740601020006421\",\"id\":\"23740600990006421\",
      # \"status_at_load\":\"1\",\"barcode\":\"32101005621469\",\"copy_number\":\"1\"}]}}
      def temporary_holding_id?
        /[a-zA-Z]\$[a-zA-Z]/.match?(holding_id)
      end

      # When it is a temporary location and is requestable, use the first holding_id of this temporary location items.
      def temporary_location_holding_id_first
        holding["items"][0]["holding_id"]
      end

      def document
        adapter.document
      end

      # The full holding hash, with the holding_id as the key
      def holding_hash
        holding_object.to_h
      end

      def items
        holding['items']
      end
end
