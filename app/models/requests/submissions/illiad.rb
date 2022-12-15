# frozen_string_literal: true

module Requests::Submissions
  class Illiad < Service
    def initialize(submission, service_type: 'ill')
      super
    end

    def handle
      items = @submission.filter_items_by_service(service_type)
      items.each do |item|
        handle_item(item)
      end
    end

    def handle_item(item)
      @handled_by = "interlibrary_loan"
      client = Requests::IlliadTransactionClient.new(patron: @submission.patron, metadata_mapper: Requests::IlliadMetadata::Loan.new(patron: @submission.patron, bib: @submission.bib, item:))
      transaction = client.create_request
      errors << { type: 'interlibrary_loan', bibid: @submission.bib, item:, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "Invalid Interlibrary Loan Request" } if transaction.blank?
      transaction
    end

    def send_mail
      return if errors.present?
      Requests::RequestMailer.send("interlibrary_loan_confirmation", submission).deliver_now
    end

    def success_message
      I18n.t('requests.submit.interlibrary_loan_success')
    end
  end
end
