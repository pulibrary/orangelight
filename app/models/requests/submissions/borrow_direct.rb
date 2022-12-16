# frozen_string_literal: true
require 'borrow_direct'

module Requests::Submissions
  class BorrowDirect < Service
    attr_reader :handled_by
    attr_reader :isbn

    def initialize(submission, service_type: 'bd')
      super
      @handled_by = "borrow_direct"
      @isbn = submission.bib["isbn"].split(" ").first if submission.bib["isbn"].present?
      @pickup_location = "Firestone Library"
    end

    def handle
      bd_items = @submission.filter_items_by_service('bd')

      # handle any borrow direct items
      bd_items.each do |bd_item|
        handle_with_borrow_direct(bd_item:)
      end

      # then handle any interlibrary loan only items
      ill_items = @submission.filter_items_by_service('ill') - bd_items
      ill_items.each do |item|
        handle_with_interlibrary_loan(item:)
      end
    end

    def success_message
      if handled_by == "borrow_direct"
        "#{I18n.t('requests.submit.bd_success')} Your request number is #{sent[0][:request_number]}"
      else
        I18n.t('requests.submit.interlibrary_loan_success')
      end
    end

    def send_mail
      return if errors.present? || handled_by == "borrow_direct"
      Requests::RequestMailer.send("interlibrary_loan_confirmation", submission).deliver_now
    end

    private

      def handle_with_borrow_direct(bd_item:)
        request_item = ::BorrowDirect::RequestItem.new(@submission.user_barcode)
        # Allow 2 minutes since these requests seem to be taking a really long time
        request_item.timeout = 200
        request_number = request_item.make_request(@pickup_location, isbn:)
        if request_number.present?
          @sent << { request_number: }
        else
          handle_with_interlibrary_loan(item: bd_item)
        end
      rescue *::BorrowDirect::Error => error
        handle_borrow_direct_error(error:, bd_item:)
      end

      def handle_borrow_direct_error(error:, bd_item:)
        # duplicate request error, do not send again
        if error.to_s.starts_with?('PRIRI003') && error.to_s.include?('duplicate')
          errors << { type: 'borrow_direct', bibid: submission.bib, item: bd_item, user_name: submission.user_name, barcode: submission.user_barcode, error: "Ignoring duplicate Borrow Direct request: #{error}" }

        # borrow direct did not work handle with interlibrary loan
        else
          Rails.logger.warn("Error with borrow direct handeling with ILL #{error.inspect}")
          handle_with_interlibrary_loan(item: bd_item)
        end
      end

      def handle_with_interlibrary_loan(item:)
        @handled_by = "interlibrary_loan"
        client = Requests::IlliadTransactionClient.new(patron: @submission.patron, metadata_mapper: Requests::IlliadMetadata::Loan.new(patron: @submission.patron, bib: @submission.bib, item:))
        transaction = client.create_request
        errors << { type: 'interlibrary_loan', bibid: @submission.bib, item:, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "Invalid Interlibrary Loan Request" } if transaction.blank?
        transaction
      end
  end
end
