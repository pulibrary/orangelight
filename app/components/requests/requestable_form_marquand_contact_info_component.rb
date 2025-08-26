# frozen_string_literal: true
module Requests
  # This component displays the contact information for Marquand Library, so that patrons can
  # contact them to request a title that is currently checked out to a carrel.
  # This is a temporary workflow until Marquand materials are all moved back and we can work
  # with Marquand staff on a more automated workflow.
  class RequestableFormMarquandContactInfoComponent < ViewComponent::Base
    def initialize(requestable:, single_item_request:)
      @requestable = requestable
      @single_item_request = single_item_request
    end

      private

        def href
          "mailto:marquand@princeton.edu?subject=#{email_subject}&body=#{email_body}"
        end

        # :reek:UtilityFunction
        def email_subject
          URI.encode_uri_component 'Requesting item in use'
        end

        def email_body
          URI.encode_uri_component "Hello, could I please use the title #{requestable.title} (barcode #{barcode})?"
        end

        def barcode
          requestable.item&.fetch 'barcode', nil
        end

        attr_reader :requestable, :single_item_request
  end
end
