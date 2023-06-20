# frozen_string_literal: true
class Requests::Requestable
  class Item < SimpleDelegator
    def pick_up_location_id
      self['pickup_location_id'] || ""
    end

    # pick_up_location_code on the item level
    def pick_up_location_code
      self['pickup_location_code'] || ""
    end

    def item_type
      self['item_type'] || ""
    end

    def description
      self[:description] || enum_value
    end

    def enum_value
      # enum_display from alma, enumeration from scsb
      [self['enum_display'], self['enumeration']].join(" ").strip
    end

    def cron_value
      self['chron_display'] || ""
    end

    def copy_number
      self[:copy_number] || ""
    end

    def copy_value
      @copy_value ||= if self[:copy_number].present? && self[:copy_number].to_i != 0 && self[:copy_number].to_i != 1
                        "Copy #{self[:copy_number]}"
                      else
                        ""
                      end
      @copy_value
    end

    def item_data?
      self[:id].present?
    end

    def temp_loc?
      self[:in_temp_library]
    end

    def in_resource_sharing?
      self[:temp_location_code] == "RES_SHARE$IN_RS_REQ"
    end

    def on_reserve?
      self[:on_reserve] == 'Y'
    end

    def inaccessible?
      status == 'Inaccessible'
    end

    def hold_request?
      status_label == 'Hold Shelf'
    end

    def preservation_conservation?
      status_label == "Preservation and Conservation"
    end

    def enumerated?
      enum_value.present?
    end

    # item type on the item level
    def item_type_non_circulate?
      ['NoCirc', 'Closed', 'Res-No'].include? item_type
    end

    def id
      self['id']
    end

    def use_statement
      self[:use_statement]
    end

    def collection_code
      self[:collection_code]
    end

    def missing?
      status_label == 'Missing'
    end

    def charged?
      unavailable_statuses.include?(status_label)
    end

    def status
      # SCSB still returns a status of "Not Available", which we should change to "Unavailable"
      return self[:status] if self[:status].present? && self[:status] != "Not Available"
      if available?
        "Available"
      else
        "Unavailable"
      end
    end

    def status_label
      self[:status_label]
    end

    def available?
      available_statuses.include?(status_label)
    end

    def barcode?
      /^[0-9]+/.match(barcode).present?
    end

    def barcode
      self[:barcode]
    end

    # Is the ReCAP Item from a partner location
    def partner_holding?
      Requests::Config[:recap_partner_locations].keys.include? self["location_code"]
    end

    private

      def available_statuses
        scsb = ["Available"]
        alma = ['Item in place']
        scsb + alma
      end

      def unavailable_statuses
        scsb = ['Not Available', "Item Barcode doesn't exist in SCSB database."]
        alma = ['Unavailable', 'Claimed Returned', 'Lost', 'Hold Shelf', 'Transit', 'Missing', 'Resource Sharing Request',
                'Lost Resource Sharing Item', 'Requested', 'In Transit to Remote Storage', 'Lost and paid',
                'Loan', 'Controlled Digital Lending', 'At Preservation', 'Technical - Migration', 'Preservation and Conservation']
        scsb + alma
      end
  end
end
