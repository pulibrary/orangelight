# frozen_string_literal: true
module Requests
  # This class assigns "services" a given requestable object is available through
  class Router
    attr_reader :patron, :any_loanable, :requestable

    def initialize(requestable:, any_loanable: false, patron: nil)
      @requestable = requestable
      @patron = patron
      @any_loanable = any_loanable
    end

    # Current Service Types Assigned
    # :aeon - material is stored in a location where it can be requested via Aeon
    # :annex - material is stored in an Annex location
    # :annex_edd - material is stored in an Annex location that is eligible for digitization
    # :annex_no_items - material is stored in an Annex location with no item record data
    # :on_shelf - material is stored in a campus library location
    # :on_shelf_edd - material is in a campus library location that is eligible for digitization
    # :on_order - material has a status in Alma that indicates it is ordered but has not yet arrived on campus
    # :in_process - material has a status in Alma that indicates it has arrived on campus but has not been processed and shelved
    # :recap - material is stored at recap; can be paged to campus and circulates
    # :recap_in_library - material is stored at recap; can be paged to campus, but does not circulate
    # :recap_edd - material is stored in a recap location that permits digitization
    # :recap_no_items - material in a recap location with no item record data
    # :ill - material has a status in Alma making it unavailable for circulation and is in a location that is eligible for resource sharing
    # :marquand_in_library - marquand item in a location that can be paged to marquand
    # :marquand_edd - marquand item in a location that is permitted to be scanned
    # :marquand_page_charged_item - a Marquand item that is charged (checked out) to somebody else's carrel, but marquand staff can retrieve it for you

    def routed_request
      requestable.replace_existing_services calculate_services
      requestable
    end

    # returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      eligibility_checks.select(&:eligible?).map(&:to_s)
    end

    private

      def eligibility_checks
        [
          ServiceEligibility::ILL.new(requestable:, patron:, any_loanable:),
          ServiceEligibility::OnOrder.new(requestable:, patron:),
          ServiceEligibility::Annex::Pickup.new(requestable:, patron:),
          ServiceEligibility::Annex::NoItems.new(requestable:, patron:),
          ServiceEligibility::OnShelfDigitize.new(requestable:, patron:),
          ServiceEligibility::OnShelfPickup.new(requestable:, patron:),
          ServiceEligibility::InProcess.new(requestable:, patron:),
          ServiceEligibility::MarquandInLibrary.new(requestable:, patron:),
          ServiceEligibility::MarquandEdd.new(requestable:, patron:),
          ServiceEligibility::MarquandPageChargedItem.new(requestable:, patron:),
          ServiceEligibility::Recap::NoItems.new(requestable:, patron:),
          ServiceEligibility::Recap::InLibrary.new(requestable:, patron:),
          ServiceEligibility::Recap::Digitize.new(requestable:, patron:),
          ServiceEligibility::Recap::Pickup.new(requestable:, patron:),
          ServiceEligibility::Aeon.new(requestable:, patron:)
        ]
      end
  end
end
