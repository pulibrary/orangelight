# frozen_string_literal: true
require 'lcsort'

module Requests
  class Pageable
    attr_reader :call_number, :location_code

    def initialize(call_number:, location_code:)
      @call_number = call_number
      @location_code = location_code
    end

    def pageable_loc?
      return nil if call_number.blank? ||
                    !paging_locations.include?(location_code)
      call_num = holding['call_number_browse']
      return nil unless lc_number?(call_num)
      in_call_num_range(call_num, pageable.paging_ranges[location_code])
    end

    private

      def lc_number?(call_num)
        Lcsort.normalize(call_num)
      end

      def in_call_num_range(call_num, ranges)
        call_num = Lcsort.normalize(call_num)
        pageable = nil
        ranges.each do |range|
          start_range = Lcsort.normalize(range[0])
          end_range = Lcsort.truncated_range_end(range[1])
          pageable = true if in_range?(call_num, start_range, end_range)
        end
        pageable
      end

      def in_range?(call_num, start_range, end_range)
        return true if call_num >= start_range && call_num <= end_range
      end

      def paging_locations
        # ['f', 'fnc', 'xl', 'xlnc', 'nec', 'necnc']
        []
      end

      def paging_ranges
        # f_ranges = [['A1', 'AZ9999'], ['Q1', 'ZZ9999']]
        # nec_ranges = [['A1', 'BL9999'], ['BT1', 'DR9999'], ['DT1', 'KA9999'], ['KG1', 'VM9999']]
        # xl_ranges = [['A1', 'ZZ9999']]
        # {
        #   'f' => f_ranges,
        #   'fnc' => f_ranges,
        #   'nec' => nec_ranges,
        #   'necnc' => nec_ranges,
        #   'xl' => xl_ranges,
        #   'xlnc' => xl_ranges
        # }
        {}
      end
  end
end
