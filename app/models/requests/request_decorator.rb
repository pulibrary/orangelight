# frozen_string_literal: true
module Requests
  # This class is responsible for generating the visual aspects of the Request object for the form
  class RequestDecorator
    delegate :patron,
             :ctx, :system_id, :language, :mfhd, :source, :holdings, :default_pick_ups,
             :serial?, :any_loanable_copies?, :requestable?, :all_items_online?,
             :thesis?, :numismatics?, :single_aeon_requestable?, :eligible_for_library_services?, :off_site?,
             :user_name, :email, # passed to request as login options on the request form
             to: :request
    delegate :content_tag, :hidden_field_tag, :concat, to: :view_context

    alias bib_id system_id

    attr_reader :request, :view_context, :first_filtered_requestable, :non_requestable_message
    def initialize(request, view_context)
      @request = request
      @view_context = view_context
      @requestable_list = request.requestable.map { |req| RequestableDecorator.new(req, view_context) }
      @first_filtered_requestable = RequestableDecorator.new(request.first_filtered_requestable, view_context)
      @non_requestable_message = "See Circulation Desk, there are no requestable items for this record"
    end

    def requestable
      @requestable_list
    end

    def catalog_url
      "/catalog/#{system_id}"
    end

    # rubocop:disable Rails/OutputSafety
    def patron_message
      return '' if patron.guest?
      return '' if eligible_for_library_services?
      "<div class='alert alert-warning'>#{I18n.t('requests.account.cas_user_no_barcode_msg')}</div>".html_safe
    end

    def hidden_fields
      hidden_request_tags = ''
      hidden_request_tags += hidden_field_tag "bib[id]", "", value: bib_id
      request.display_metadata.each do |key, value|
        hidden_request_tags += hidden_field_tag "bib[#{key}]", "", value:
      end
      hidden_request_tags.html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def any_will_submit_via_form?
      return false if requestable.compact_blank.blank? || !eligible_for_library_services?
      requestable.map(&:will_submit_via_form?).any? || any_fill_in_eligible?
    end

    def any_fill_in_eligible?
      return false unless eligible_for_library_services?
      return false if patron.alma_provider?

      fill_in = false
      unless (requestable.count == 1) && (requestable.first.services & ["on_order", "online"]).present?
        if requestable.any? do |requestable_decorator|
          !(requestable_decorator.services & fill_in_services).empty?
        end
          if any_items?
            fill_in = true if any_enumerated?
          elsif request.too_many_items?
            fill_in = true
          else
            fill_in = any_circulate?
          end
        end
      end
      fill_in
    end

    def single_item_request?
      requestable.size == 1 && !any_fill_in_eligible?
    end

    def only_aeon?
      requestable.map(&:aeon?).all?
    end

    def location_label
      return "" if holding.blank?
      first_requestable_item = requestable.first.item if any_items?
      if any_items? && first_requestable_item.temp_loc_other_than_resource_sharing?
        current_location_label
      else
        permanent_location_label
      end
    end

    def current_location_label
      label = holding["current_library"]
      current_holding_location = holding['current_location']
      label += " - #{current_holding_location}" if current_holding_location.present?
      label
    end

    def permanent_location_label
      label = holding["library"]
      holding_location = holding['location']
      label += " - #{holding_location}" if holding_location.present?
      label
    end

    def holding
      first_requestable_item = requestable.first.item if any_items?
      if any_items? && first_requestable_item.temp_loc_other_than_resource_sharing?
        holdings[first_requestable_item["temp_location_code"]]
      else
        holdings[mfhd]
      end
    end

    def alma_provider_item_unavailable?
      patron.alma_provider? && !(any_available? || any_in_process?)
    end

    private

      def fill_in_services
        ["annex", "recap_no_items", "on_shelf"]
      end

      def any_circulate?
        requestable.any?(&:circulates?)
      end

      def any_enumerated?
        requestable.any?(&:enumerated?)
      end

      def any_items?
        requestable.any?(&:item_data?)
      end

      def any_available?
        requestable.any?(&:available?)
      end

      def any_in_process?
        requestable.any?(&:in_process?)
      end
  end
end
