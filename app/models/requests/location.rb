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

    def fulfillment_unit
      bibdata_fulfillment_unit = bibdata_location['fulfillment_unit']
      return nil if bibdata_fulfillment_unit.blank?
      bibdata_fulfillment_unit
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

    def engineering_library?
      short_label == "Engineering Library"
    end

    def standard_circ_location?
      return false if code.blank?

      code.start_with?("arch$", "eastasian$", "engineer$", "firestone$", "plasma$", "lewis", "mendel$", "stokes$") && fulfillment_unit == 'General'
    end

    def self.valid_recap_annex_pickup?(location_hash)
      ['PJ', 'PA', 'PL', 'PK', 'PM', 'PT', 'QX', 'PW', 'QA', 'QT', 'QC'].include?(location_hash[:gfa_pickup])
    end

    ## Accepts an array of location hashes and sorts them according to our quirks
    def sort_pick_ups
      self.class.sort_pick_up_locations(delivery_locations)
    end

    ## Class method to sort any array of pickup locations
    # :reek:TooManyStatements
    # :reek:DuplicateMethodCall
    def self.sort_pick_up_locations(locations)
      # staff only locations go at the bottom of the list, the rest sort by label

      public_locations = locations.select { |loc| loc[:staff_only] == false }
      public_locations.sort_by! { |loc| loc[:label] }

      staff_locations = locations.select { |loc| loc[:staff_only] == true }
      staff_locations.sort_by! { |loc| loc[:label] }

      staff_locations.each do |loc|
        loc[:label] = loc[:label] + " (Staff Only)"
      end
      public_locations + staff_locations
    end

    def build_delivery_locations
      delivery_locations.map do |loc|
        library = loc["library"]
        pick_up_code = library.present? && library["code"]
        pick_up_code ||= 'firestone'
        loc.merge("pick_up_location_code" => pick_up_code) { |_key, v1, _v2| v1 }
      end
    end

      private

        def library_data_present?
          bibdata_location["library"].present?
        end

        attr_reader :bibdata_location
  end
end
