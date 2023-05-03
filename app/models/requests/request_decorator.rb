# frozen_string_literal: true
module Requests
  class RequestDecorator
    delegate :patron,
             :ctx, :system_id, :language, :mfhd, :source, :holdings, :default_pick_ups,
             :serial?, :any_loanable_copies?, :requestable?, :all_items_online?,
             :thesis?, :numismatics?, :single_aeon_requestable?, :eligible_for_library_services?, :off_site?,
             :user_name, :email, # passed to request as login options on the request form
             to: :request
    delegate :content_tag, :hidden_field_tag, :concat, to: :view_context

    alias bib_id system_id

    attr_reader :request, :view_context, :first_filtered_requestable, :non_requestable_mesage
    def initialize(request, view_context)
      @request = request
      @view_context = view_context
      @requestable_list = request.requestable.map { |req| RequestableDecorator.new(req, view_context) }
      @first_filtered_requestable = RequestableDecorator.new(request.first_filtered_requestable, view_context)
      @non_requestable_mesage = "See Circulation Desk, there are no requestable items for this record"
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

    def format_brief_record_display
      params = request.display_metadata
      content_tag(:dl, class: "dl-horizontal") do
        params.each do |key, value|
          if value.present? && display_label[key].present?
            concat content_tag(:dt, display_label[key].to_s)
            concat content_tag(:dd, value.first.to_s, lang: request.language.to_s, id: display_label[key].gsub(/[^0-9a-z ]/i, '').downcase.to_s)
          end
        end
      end
    end

    def any_will_submit_via_form?
      return false if requestable.compact_blank.blank? || !eligible_for_library_services?
      requestable.map(&:will_submit_via_form?).any? || any_fill_in_eligible?
    end

    def any_fill_in_eligible?
      return false unless eligible_for_library_services?
      return false if patron.alma_provider?

      fill_in = false
      unless (requestable.count == 1) && (requestable.first.services & ["on_order", "online"]).present?
        if requestable.any? { |r| !(r.services & fill_in_services).empty? }
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
      if any_items? && requestable.first.item.temp_loc? && !requestable.first.item.in_resource_sharing?
        label = holding["current_library"]
        label += " - #{holding['current_location']}" if holding["current_location"].present?
      else
        label = holding["library"]
        label += " - #{holding['location']}" if holding["location"].present?
      end
      label
    end

    def holding
      if any_items? && requestable.first.item.temp_loc? && !requestable.first.item.in_resource_sharing?
        holdings[requestable.first.item["temp_location_code"]]
      else
        holdings[mfhd]
      end
    end

    def alma_provider_on_shelf_item_available?
      patron.alma_provider?  && !off_site? && any_available?
    end

    def alma_provider_item_unavailable?
      patron.alma_provider?  && !(any_available? || any_in_process?)
    end

    private

      def display_label
        {
          author: "Author/Artist",
          title: "Title",
          date: "Published/Created",
          id: "Bibliographic ID",
          mfhd: "Holding ID (mfhd)"
        }.with_indifferent_access
      end

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
