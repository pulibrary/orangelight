module Requests
  class RequestDecorator
    delegate :patron,
             :ctx, :system_id, :language, :mfhd, :source, :holdings, :default_pick_ups,
             :serial?, :borrow_direct_eligible?, :any_loanable_copies?, :requestable?, :all_items_online?,
             :thesis?, :numismatics?, :single_aeon_requestable?, :eligible_for_library_services?,
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
      return "" if (patron.campus_authorized && !first_filtered_requestable.etas?) || patron.guest?
      "<div class='alert alert-warning'>#{patron_message_internal}</div>".html_safe
    end

    def hidden_fields
      hidden_request_tags = ''
      hidden_request_tags += hidden_field_tag "bib[id]", "", value: bib_id
      request.display_metadata.each do |key, value|
        hidden_request_tags += hidden_field_tag "bib[#{key}]", "", value: value
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
      return false if requestable.reject(&:blank?).blank? || !eligible_for_library_services?
      requestable.map(&:will_submit_via_form?).any? || any_fill_in_eligible?
    end

    def any_fill_in_eligible?
      return false unless eligible_for_library_services?

      fill_in = false
      unless (requestable.count == 1) && (requestable.first.services & ["on_order", "online"]).present?
        if requestable.any? { |r| !(r.services & fill_in_services).empty? }
          if any_items?
            fill_in = true if any_enumerated?
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
      label = holding["library"]
      label += " - #{holding['location']}" if holding["location"].present?
      label
    end

    def holding
      holdings[mfhd]
    end

    private

      def patron_message_internal
        if first_filtered_requestable.etas?
          etas_message
        elsif patron.pick_up_only?
          "You are only currently authorized to utilize our book <a href='https://library.princeton.edu/services/book-pick-up'>pick-up service</a>. Please consult with <a href='mailto:refdesk@princeton.edu'>refdesk@princeton.edu</a> if you would like to book time to spend in our libraries using our <a href='https://library.princeton.edu/services/study-browse'>study-browse service</a>."
        elsif !eligible_for_library_services?
          I18n.t("requests.account.cas_user_no_barcode_msg")
        elsif !patron.guest? && !patron.campus_authorized
          msg = "You are not currently authorized for on-campus services at the Library. Please send an inquiry to <a href='mailto:refdesk@princeton.edu'>refdesk@princeton.edu</a> if you believe you should have access to these services."
          msg += "  If you would like to have access to pick-up books <a href='https://ehs.princeton.edu/COVIDTraining'>please complete the mandatory COVID-19 training</a>." if patron.training_eligable?
          msg
        end
      end

      def etas_message
        "We currently cannot lend this item" +
          if first_filtered_requestable.etas_limited_access
            " from our ReCAP partner collection because of changes in copyright restrictions."
          else
            ", but you may view an online copy via the <a href='#{catalog_url}'>link in the record page</a>"
          end
      end

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
  end
end
