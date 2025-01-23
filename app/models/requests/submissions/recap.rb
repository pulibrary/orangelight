# frozen_string_literal: true
require 'faraday'

module Requests::Submissions
  class Recap < Service
    include Requests::Scsb

    def initialize(submission, service_type: 'recap')
      super
    end

    def handle
      items = submission.filter_items_by_service(service_type)
      items.each do |item|
        handle_item(item)
      end
    end

    def send_mail
      return if errors.present?
      hashed_submission = submission.to_h # Sidekiq will only accept a hash, not a Requests::Submission object
      Requests::RequestMailer.send("#{service_type}_email", hashed_submission).deliver_later unless ['recap_edd', 'recap'].include?(service_type)
      Requests::RequestMailer.send("#{service_type}_confirmation", hashed_submission).deliver_later
    end

    private

      def handle_item(item)
        params = scsb_param_mapping(submission.bib, submission.patron, item)
        response = scsb_request(params)
        if response.status != 200
          error_message = "Request failed because #{response.body}"
          @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode, error: error_message }
        else
          response = parse_scsb_response(response)
          if response[:success] == false
            @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode, error: response[:screenMessage] }
          else
            @sent << { bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode }
            handle_hold_for_item(item)
          end
        end
      rescue JSON::ParserError
        @errors << { type: 'recap', bibid: params[:bibId], item: params[:itemBarcodes], user_name: submission.user_name, barcode: submission.user_barcode, error: "Invalid response from the SCSB server: #{response.body}" }
      end

      def handle_hold_for_item(item)
        return if submission.partner_item?(item) || submission.edd?(item)

        hold = Requests::Submissions::HoldItem.new(@submission, service_type: "recap")
        hold.handle_item(item:)
        return if hold.errors.empty?
        hold.errors.map! do |error|
          reply_text = error["reply_text"]
          error.merge("reply_text" => "Recap request was successful, but creating the hold in Alma had an error: #{reply_text}")
        end
        service_errors = hold.error_hash
        send_error_email(service_errors, @submission)
      end

      # This has to be a utility function to prevent ActiveJob from trying to serialize too many objects
      # :reek:UtilityFunction
      def send_error_email(errors, submission)
        Requests::RequestMailer.send("service_error_email", errors, submission.to_h).deliver_later
      end
  end
end
