# frozen_string_literal: true
module Requests
  # This class assigns "services" a given requestable object is available through
  class Router
    attr_reader :user, :any_loanable, :requestable

    delegate :cas_provider?, :alma_provider?, to: :user

    def initialize(requestable:, user:, any_loanable: false)
      @requestable = requestable
      @user = user
      @any_loanable = any_loanable
    end

    # Current Service Types Assigned
    # :online - material is available online at a URL
    # :aeon - material is stored in a location where it can be requested via Aeon
    # :annex - material is stored in an Annex location
    # :on_shelf - material is stored in a campus library location
    # :on_shelf_edd - material is in a campus library location that is eligible for digitization
    # :on_order - material has a status in Alma that indicates it is ordered but has not yet arrived on campus
    # :in_process - material has a status in Alma that indicates it has arrived on campus but has not been processed and shelved
    # :recap - material is stored at recap; can be paged to campus and circulates
    # :recap_in_library - material is stored at recap; can be paged to campus, but does not circulate
    # :recap_edd - material is stored in a recap location that permits digitization
    # :recap_no_items - material in a recap location with item record data
    # :ill - material has a status in Alma making it unavailable for circulation and is in a location that is eligible for resource sharing
    # :clancy_unavailable - item is at clancy but clancy system says it is not available; but it's alma status is available
    # :clancy_in_library - item in the clancy warehouse and can be paged to marquand
    # :clancy_edd - item in the clancy warehouse in a location that permits digitization
    # :marquand_in_library - non clancy marquand item in a location that can be paged to marquand
    # :marquand_edd - non clancy marquand item in a location that is permitted to be scanned
    # :ask_me - catchall service if the item isn't eligible for anything else.

    def routed_request
      requestable.replace_existing_services calculate_services
      requestable
    end

    # top level call, returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      if (requestable.alma_managed? || requestable.partner_holding?) && !requestable.aeon?
        calculate_alma_or_scsb_services
      else # Default Service is Aeon
        ['aeon']
      end
    end

    private

      # rubocop:disable Metrics/MethodLength
      def calculate_alma_or_scsb_services
        return [] unless auth_user?
        if requestable.charged?
          calculate_unavailable_services
        elsif requestable.in_process?
          ['in_process']
        elsif requestable.on_order?
          ['on_order']
        elsif requestable.annex?
          ['annex', 'on_shelf_edd']
        elsif requestable.recap? || requestable.recap_pf?
          calculate_recap_services
        elsif requestable.held_at_marquand_library?
          calculate_marquand_services
        else
          calculate_on_shelf_services
        end
      end
      # rubocop:enable Metrics/MethodLength

      def calculate_on_shelf_services
        [
          ServiceEligibility::OnShelfDigitize.new(requestable:, user:),
          ServiceEligibility::OnShelfPickup.new(requestable:, user:)
        ].select(&:eligible?).map(&:to_s)
      end

      def calculate_recap_services
        if !requestable.item_data?
          ['recap_no_items']
        elsif (requestable.scsb_in_library_use? && requestable.item[:collection_code] != "MR") || (!requestable.circulates? && !requestable.recap_edd?) || requestable.recap_pf?
          ['recap_in_library']
        elsif requestable.scsb_in_library_use? && !requestable.eligible_for_library_services?
          ['ask_me']
        elsif auth_user?
          services = []
          services << 'recap' if !requestable.holding_library_in_library_only? && requestable.circulates? && requestable.eligible_for_library_services?
          services << 'recap_edd' if requestable.recap_edd?
          services
        end
      end

      def calculate_unavailable_services
        ill_eligibility = ServiceEligibility::ILL.new(requestable:, user:, any_loanable:)
        if ill_eligibility.eligible?
          [ill_eligibility.to_s]
        else
          []
        end
      end

      def calculate_marquand_services
        clancy_services = [
          ServiceEligibility::ClancyUnavailable.new(user:, requestable:),
          ServiceEligibility::ClancyInLibrary.new(user:, requestable:),
          ServiceEligibility::ClancyEdd.new(user:, requestable:)
        ].select(&:eligible?).map(&:to_s)
        if clancy_services.any?
          clancy_services
        else
          ['marquand_in_library', 'marquand_edd']
        end
      end

      def auth_user?
        cas_provider? || alma_provider?
      end
  end
end
