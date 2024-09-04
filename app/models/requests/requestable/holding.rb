# frozen_string_literal: true
module Requests
  class Requestable
    # This class is responsible for answering questions about a
    # particular holding, based on data from a hash (which is
    # a parsed holdings_1display solr document field)
    class Holding
      def initialize(hash)
        @hash = hash.with_indifferent_access
      end

      def to_h
        @hash
      end

      def thesis?
        to_h.key?("thesis") && to_h["thesis"][:location_code] == 'mudd$stacks'
      end

      def numismatics?
        to_h.key?("numismatics") && to_h["numismatics"][:location_code] == 'rare$num'
      end

      def holding_data
        to_h.values&.first || {}
      end
    end
  end
end
