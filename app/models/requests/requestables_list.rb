# frozen_string_literal: true
module Requests
  # This class is a factory that is responsible for creating
  # a list of Requestables based on the provided document and
  # holdings data
  class RequestablesList
    include Bibdata
    include Scsb

    def initialize(document:, holdings:, location:, mfhd:, patron:)
      @document = document
      @holdings = holdings
      @location = location
      @mfhd = mfhd
      @patron = patron
    end

    def to_a
      if document._source.blank?
        []
      elsif too_many_items?
        TooManyItemsFactory.new(document:, holding:, location:, patron:).call
      elsif document.scsb_record?
        ScsbItemsFactory.new(document:, holdings:, location:, patron:).call
      elsif items.present?
        AlmaItemsFactory.new(document:, holdings:, items:, location:, mfhd:, patron:).call
      else
        NoItemsFactory.new(document:, holding:, location:, patron:).call
      end
    end

    def too_many_items?
      holding.items&.count&.> 500
    end

    ## Loads item availability through the Request Bibdata service using the items_by_mfhd method
    # items_by_mfhd makes the availability call:
    # bibdata_conn.get "/bibliographic/#{system_id}/holdings/#{mfhd_id}/availability.json"
    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def items
      return nil unless system_id
      return nil if too_many_items?
      @items ||= begin
        mfhd_items = { mfhd => items_by_mfhd(system_id, mfhd) }
        mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
      end
    end

    private

      attr_reader :document, :holdings, :location, :mfhd, :patron

      def system_id
        document.id
      end

      def holding
        Holding.new(mfhd_id: mfhd, holding_data: holdings[mfhd])
      end
  end
end
