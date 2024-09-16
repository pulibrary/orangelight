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
    # :aeon - material is stored in a location where it can be requested via Aeon
    # :annex - material is stored in an Annex location
    # :on_shelf - material is stored in a campus library location
    # :on_shelf_edd - material is in a campus library location that is eligible for digitization
    # :on_order - material has a status in Alma that indicates it is ordered but has not yet arrived on campus
    # :in_process - material has a status in Alma that indicates it has arrived on campus but has not been processed and shelved
    # :recap - material is stored at recap; can be paged to campus and circulates
    # :recap_in_library - material is stored at recap; can be paged to campus, but does not circulate
    # :recap_edd - material is stored in a recap location that permits digitization
    # :recap_no_items - material in a recap location with no item record data
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

    # returns a hash of symbols with service objects as values
    # services[:service_name] = Requests::Service::GenericService
    def calculate_services
      eligibility_checks.select(&:eligible?).map(&:to_s)
    end

    private

      def eligibility_checks
        [
          ServiceEligibility::ILL.new(requestable:, user:, any_loanable:),
          ServiceEligibility::OnOrder.new(requestable:, user:),
          ServiceEligibility::Annex.new(requestable:, user:),
          ServiceEligibility::OnShelfDigitize.new(requestable:, user:),
          ServiceEligibility::OnShelfPickup.new(requestable:, user:),
          ServiceEligibility::ClancyUnavailable.new(user:, requestable:),
          ServiceEligibility::ClancyInLibrary.new(user:, requestable:),
          ServiceEligibility::ClancyEdd.new(user:, requestable:),
          ServiceEligibility::InProcess.new(requestable:, user:),
          ServiceEligibility::MarquandInLibrary.new(user:, requestable:),
          ServiceEligibility::MarquandEdd.new(user:, requestable:),
          ServiceEligibility::Recap::NoItems.new(requestable:, user:),
          ServiceEligibility::Recap::InLibrary.new(requestable:, user:),
          ServiceEligibility::Recap::AskMe.new(requestable:, user:),
          ServiceEligibility::Recap::Digitize.new(requestable:, user:),
          ServiceEligibility::Recap::Pickup.new(requestable:, user:),
          ServiceEligibility::Aeon.new(requestable:)
        ]
      end
  end
end
