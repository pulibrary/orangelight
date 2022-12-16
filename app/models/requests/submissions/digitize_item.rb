# frozen_string_literal: true
require 'faraday'

module Requests::Submissions
  class DigitizeItem < Service
    def initialize(submission, service_type: 'digitize')
      super
      @service_types = { digitize: { cited_pages: 'COVID-19 Campus Closure', note: 'Digitization Request' },
                         annex_edd: { cited_pages: 'Annex EDD', note: 'Digitization Request Forrestal Annex Item' },
                         marquand_edd: { cited_pages: 'Marquand EDD', note: 'Digitization Request Marquand Item' },
                         clancy_edd: { cited_pages: 'Marquand Clancy EDD', note: 'Digitization Request Marquand Item at Clancy' },
                         clancy_unavailable_edd: { cited_pages: 'Marquand Clancy UNAVAIL EDD', note: 'Digitization Request Marquand Item at Clancy (Unavailable)' } }
    end

    def handle
      params = @service_types[service_type.to_sym]
      items = @submission.filter_items_by_service(service_type)
      items.each do |item|
        item_status = handle_item(item:, **params)
        if item_status.present?
          item["transaction_number"] = item_status["TransactionNumber"].to_s
          @sent << item_status if item_status.present?
        end
      end
      return false if @errors.present?
    end

    def submitted
      @sent
    end

    private

      def handle_item(item:, note:, cited_pages:)
        client = Requests::IlliadTransactionClient.new(patron: @submission.patron, metadata_mapper: Requests::IlliadMetadata::ArticleExpress.new(patron: @submission.patron, bib: @submission.bib, item:, note:, cited_pages:))
        transaction = client.create_request
        errors << { type: 'digitize', bibid: @submission.bib, item:, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "Invalid Illiad Patron" } if transaction.blank?
        if transaction == "DISAVOWED"
          errors << { type: 'digitize', bibid: @submission.bib, item:, user_name: @submission.user_name, barcode: @submission.user_barcode, error: "You no longer have an active account and may not make digitization requests." }
          transaction = nil
        end
        transaction
      end
  end
end
