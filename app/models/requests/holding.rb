# frozen_string_literal: true
module Requests
  # This class is responsible for answering questions about a
  # particular holding, based on data from a hash (which is
  # typically taken from a parsed holdings_1display solr
  # document field)
  class Holding
    def initialize(mfhd_id:, holding_data:)
      @mfhd_id = mfhd_id
      @holding_data = holding_data&.with_indifferent_access || {}
    end

    attr_reader :holding_data, :mfhd_id

    def to_h
      Hash[mfhd_id, holding_data].with_indifferent_access
    end

    def full_location_name
      "#{library_name} - #{location_name}"
    end

    private

      def library_name
        holding_data['current_library'] || holding_data['library']
      end

      def location_name
        holding_data['current_location'] || holding_data['location']
      end
  end
end
