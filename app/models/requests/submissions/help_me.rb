# frozen_string_literal: true
module Requests::Submissions
  class HelpMe < Service
    def initialize(submission)
      super(submission, service_type: 'help_me')
      @submission = submission
    end

    def handle
      items = @submission.filter_items_by_service(service_type)
      items.each do |item|
        handle_with_illiad(item:)
      end
    end

    private

      def handle_with_illiad(item:)
        patron = @submission.patron
        client = Requests::IlliadTransactionClient.new(patron:, metadata_mapper: Requests::IlliadMetadata::Loan.new(patron:, bib: @submission.bib, item:, note: patron_note))
        transaction = client.create_request
        errors << { type: 'help_me', bibid: @submission.bib, item:, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "Invalid Help Me Request" } if transaction.blank?
        transaction
      end

      def patron_note
        "Help Me Get It Request: User has access to physical item pickup"
      end
  end
end
