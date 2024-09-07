# frozen_string_literal: true
module Requests
  # This class is responsible for answering questions about
  # a location, based on data supplied from a bibdata hash
  class Location
    # @param bibdata_location [Hash] The hash for a bibdata holding (https://bibdata.princeton.edu/locations/holding_locations)
    def initialize(bibdata_location)
      @bibdata_location = bibdata_location.to_h.with_indifferent_access
    end

    def code
      return nil if bibdata_location.blank?
      bibdata_location['code']
    end

    def short_label
      bibdata_location["label"]
    end

    def location_label
      return nil unless library_data_present?
      label = library_label
      label += " - #{short_label}" if short_label.present?
      label
    end

    def library_code
      bibdata_location.dig('library', 'code')
    end

    def library_label
      bibdata_location.dig('library', 'label')
    end

    def valid?
      bibdata_location.key?(:library) && bibdata_location[:library].key?(:code)
    end

    def aeon?
      bibdata_location[:aeon_location] == true
    end

    def annex?
      valid? && library_code == 'annex'
    end

    def circulates?
      bibdata_location[:circulates] == true
    end

    def always_requestable?
      bibdata_location[:always_requestable] == true
    end

    def holding_library
      bibdata_location[:holding_library]
    end

    def delivery_locations
      bibdata_location[:delivery_locations] || []
    end

    def to_h
      bibdata_location
    end

    def recap?
      bibdata_location[:remote_storage] == "recap_rmt"
    end

      private

        def library_data_present?
          bibdata_location["library"].present?
        end

        attr_reader :bibdata_location
  end
end
