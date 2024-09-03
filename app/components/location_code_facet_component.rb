# frozen_string_literal: true

class LocationCodeFacetComponent < ViewComponent::Base
  include Blacklight::FacetsHelperBehavior
  include ApplicationHelper

  attr_reader :display_facet, :label, :blacklight_config, :search_state

  def initialize(display_facet:, label:, blacklight_config:, search_state:)
    @display_facet = display_facet
    @label = label
    @blacklight_config = blacklight_config
    @search_state = search_state
  end

  def libraries_and_locations
    @libraries_and_locations ||= fetch_libraries_and_locations
  end

  def location_codes_by_lib(facet_items)
    locations = {}
    non_code_items = []
    facet_items.each do |item|
      holding_loc = Bibdata.holding_locations[item.value]
      holding_loc.nil? ? non_code_items << item : add_holding_loc(item, holding_loc, locations)
    end
    library_facet_values(non_code_items, locations)
    locations.sort.to_h
  end

    private

      def fetch_libraries_and_locations
        values = []
        return values if display_facet.items.blank?
        location_codes_by_lib(display_facet.items).each do |library, items|
          library_display = items['item'].nil? ? library : "#{library} (#{number_with_delimiter(items['item'].hits)})"
          values << {
            value: library,
            label: library_display,
            selected: facet_value_checked?(display_facet.name, library)
          }
          items['recap_codes'].concat(items['codes']).each do |facet_item|
            item_label = facet_item_presenter(blacklight_config.facet_configuration_for_field(display_facet.name), facet_item.value, display_facet.name).label
            values << {
              value: facet_item.value,
              label: item_label,
              selected: facet_value_checked?(display_facet.name, facet_item.value)
            }
          end
        end
        values << pul_facet_value
        values
      end

      def pul_facet_value
        {
          value: 'pul',
          label: 'pul',
          selected: facet_value_checked?(display_facet.name, 'pul')
        }
      end

      def add_holding_loc(item, holding_loc, locations)
        library = holding_loc['library']['label']
        add_library(library, locations)
        locations[library]['codes'] << item
        add_scsb_loc(item, holding_loc, locations)
      end

      def add_scsb_loc(item, holding_loc, locations)
        return if holding_loc['holding_library'].nil?
        library = holding_loc['holding_library']['label']
        add_library(library, locations)
        locations[library]['recap_codes'] << item
      end

      def add_library(library, locations)
        locations[library] = { 'codes' => [], 'recap_codes' => [] } if locations[library].nil?
      end

      def library_facet_values(non_code_items, locations)
        non_code_items.each do |item|
          locations[item.value]['item'] = item if locations.key?(item.value)
        end
      end
end
