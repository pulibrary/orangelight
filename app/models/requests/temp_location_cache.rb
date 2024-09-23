# frozen_string_literal: true

module Requests
  # This class is responsible for caching a list of temporary
  # locations in memory
  class TempLocationCache
    include Requests::Bibdata

    def initialize
      @temp_locations = {}
    end

    def retrieve(item_location_code)
      @temp_locations[item_location_code] ||= get_location_data(item_location_code)
    end
  end
end
