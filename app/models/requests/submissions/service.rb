# frozen_string_literal: true
module Requests::Submissions
  class Service
    attr_reader :service_type, :success_message, :submission, :errors, :sent

    def initialize(submission, service_type:)
      @submission = submission
      @sent = [] # array of hashes of bibid and item_ids for each successfully sent item
      @errors = [] # array of hashes with bibid and item_id and error message
      @service_type = service_type
      @success_message = I18n.t("requests.submit.#{service_type}_success", default: I18n.t('requests.submit.success'))
    end

    def handle
      raise NotImplementedError
    end

    def submitted
      @sent
    end

    # This has to be a utility function to prevent ActiveJob from trying to serialize too many objects
    # :reek:UtilityFunction
    def send_mail
      return if errors.present?
      Requests::RequestMailer.send("#{service_type}_email", submission).deliver_later
      Requests::RequestMailer.send("#{service_type}_confirmation", submission).deliver_later
    end

    def error_hash
      errors = @errors.map { |error| { type: error[:type], error: error[:error], bibid: error[:bibid], barcode: error[:barcode], reply_text: error[:reply_text] } }
      [[@service_type, errors]].to_h
    end
  end
end
