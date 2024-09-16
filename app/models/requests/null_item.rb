# frozen_string_literal: true
module Requests
  class NullItem < Requests::Item
    def nil?
      true
    end

    def present?
      false
    end

    def blank?
      true
    end

    def item_data?
      false
    end

    def pick_up_location_code
      ""
    end

    def item_type
      ""
    end

    def enum_value
      ""
    end

    def cron_value
      ""
    end

    def copy_value
      ""
    end

    def temp_loc?
      ""
    end

    def in_resource_sharing?
      false
    end

    def temp_loc_other_than_resource_sharing?
      false
    end

    def on_reserve?
      false
    end

    def enumerated?
      false
    end

    def item_type_non_circulate?
      false
    end

    def id
      nil
    end

    def use_statement
      ''
    end

    def collection_code
      ''
    end

    def charged?
      false
    end

    def status_label
      ''
    end

    def status
      'Unavailable'
    end

    def available?
      false
    end

    def barcode?
      false
    end

    def barcode
      ''
    end

    def partner_holding?
      false
    end

    def location
      nil
    end
  end
end
