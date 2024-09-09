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
      { mfhd_id: holding_data }
    end

    def thesis?
      mfhd_id == "thesis" && holding_data[:location_code] == 'mudd$stacks'
    end

    def numismatics?
      mfhd_id == "numismatics" && holding_data[:location_code] == 'rare$num'
    end
  end
end
