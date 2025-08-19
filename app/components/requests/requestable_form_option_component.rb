# frozen_string_literal: true
module Requests
  # This component is responsible for rendering a Requests::Requestable as an option that a user
  # can select from the Requests form.
  class RequestableFormOptionComponent < ViewComponent::Base
    with_collection_parameter :requestable
    def initialize(requestable:, mfhd:, default_pick_ups:, form:, patron:)
      @requestable = requestable
      @mfhd = mfhd
      @default_pick_ups = default_pick_ups
      @form = form
      @patron = patron
    end

    def call
      render partial:, locals:
    end

    def render?
      partial
    end

    delegate :digitize?, :in_library_use_required?, :pick_up?, to: :requestable

      private

        # :reek:TooManyStatements
        def partial
          if !requestable.will_submit_via_form? && patron.alma_provider?
            'requestable_form_alma_login'
          elsif requestable.aeon?
            'requestable_form_aeon'
          elsif digitize? && pick_up?
            'requestable_form_digitize_and_pick_up'
          elsif pick_up?
            'requestable_form_pick_up'
          elsif digitize? && in_library_use_required?
            'requestable_form_digitize_and_in_library_use'
          elsif digitize?
            'requestable_form_digitize'
          elsif requestable.ill_eligible?
            'requestable_form_illiad'
          elsif requestable.request?
            'requestable_form_request'
          elsif in_library_use_required?
            'requestable_form_in_library_use'
          end
        end

        def locals
          { requestable: requestable, mfhd: mfhd, default_pick_ups: default_pick_ups, request_context: form.ctx, single_item_request: form.single_item_request? }
        end

        attr_reader :requestable, :mfhd, :default_pick_ups, :form, :patron
  end
end
