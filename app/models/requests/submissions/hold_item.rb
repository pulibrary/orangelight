# frozen_string_literal: true
require 'faraday'

module Requests::Submissions
  class HoldItem < Service
    attr_accessor :duplicate

    def initialize(submission, service_type: 'on_shelf')
      super
      @duplicate = false
    end

    def handle
      items = submission.filter_items_by_service(service_type)
      items.each do |item|
        item_status = handle_item(item: item)
        @sent << item_status if item_status.present?
      end
      return false if @errors.present?
    end

    def duplicate?
      duplicate
    end

    def handle_item(item:)
      status = {}
      begin
        status = if item["user_supplied_enum"].present?
                   item # noop - Alma can not create the correct hold.  This assumes the correct emails will go out during send_mail
                 else
                   place_hold(item)
                 end
      rescue Alma::BibRequest::ItemAlreadyExists
        status = item.merge(payload: payload(item), response: "DuplicateRequest")
        @duplicate = true
      rescue StandardError => invalid
        errors << { reply_text: "Can not create hold", create_hold: { note: "Hold can not be created", message: invalid.message } }.merge(submission.bib.to_h).merge(item.to_h).with_indifferent_access
      end
      status
    end

    def success_message
      if duplicate?
        I18n.t("requests.submit.duplicate")
      else
        I18n.t("requests.submit.#{service_type}_success", default: I18n.t('requests.submit.success'))
      end
    end

    def send_mail
      return if duplicate?
      super
    end

    private

      def place_hold(item)
        status = {}
        options = payload(item)
        response = Requests::AlmaHoldRequest.submit(options)
        if response.success?
          status = item.merge(payload: options, response: response.raw_response.parsed_response)
        else
          errors << reponse_json["response"].merge(submission.bib.to_h).merge(item.to_h).merge(type: service_type)
        end
        status
      end

      def payload(item)
        pick_up_library = if item["pick_up_location_code"] == "annex"
                            "firestone"
                          else
                            item["pick_up_location_code"]
                          end

        { mms_id: submission.bib['id'], holding_id: item["mfhd"], item_pid: item['item_id'], user_id: submission.patron.university_id, request_type: "HOLD", pickup_location_type: "LIBRARY", pickup_location_library: pick_up_library }
      end
  end
end
