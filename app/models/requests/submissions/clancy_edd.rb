# frozen_string_literal: true
require 'faraday'

module Requests::Submissions
  class ClancyEdd < Service
    def initialize(submission)
      super(submission, service_type: 'clancy_edd')
    end

    def handle
      items = @submission.filter_items_by_service(service_type)
      items.each do |item|
        handle_item(item)
      end
    end

    private

      def handle_item(item)
        # place the item on hold
        digitize = Requests::Submissions::DigitizeItem.new(@submission, service_type: service_type)
        digitize.handle
        if digitize.errors.empty?
          # request it from the clancy facility
          clancy_item = Requests::ClancyItem.new(barcode: item[:barcode])
          status = clancy_item.request(patron: @submission.patron, hold_id: hold_id(item_barcode: item[:barcode], patron_barcode: @submission.patron.barcode))
          @errors << { type: 'clancy', error: clancy_item.errors.first } unless status
        else
          @errors << digitize.errors.first.merge(type: 'clancy_edd')
        end
      end

      def hold_id(item_barcode:, patron_barcode:)
        id = "#{item_barcode}-#{patron_barcode}-#{Time.zone.now.to_i}"
        Rails.logger.debug("Requesting clancy item with id: #{id}")
        id
      end
  end
end
