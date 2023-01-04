# frozen_string_literal: true
require 'faraday'

module Requests::Submissions
  class Clancy < Service
    def initialize(submission)
      super(submission, service_type: 'clancy_in_library')
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
        hold = Requests::Submissions::HoldItem.new(@submission, service_type: item["type"])
        hold.handle

        if hold.errors.empty?
          # request it from the clancy facility
          clancy_item = Requests::ClancyItem.new(barcode: item[:barcode])
          status = clancy_item.request(patron: @submission.patron, hold_id: hold_id(item_barcode: item[:barcode], patron_barcode: @submission.patron.barcode))
          @errors << { type: 'clancy', error: clancy_item.errors.first, bibid: item[:bibid], barcode: item[:barcode] } unless status
        else
          @errors << hold.errors.first.merge(type: 'clancy_hold')
        end
      end

      def hold_id(item_barcode:, patron_barcode:)
        id = "#{item_barcode}-#{patron_barcode}-#{Time.zone.now.to_i}"
        Rails.logger.debug { "Requesting clancy item with id: #{id}" }
        id
      end
  end
end
