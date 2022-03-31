# frozen_string_literal: true
require 'borrow_direct'

module Requests
  class BorrowDirectLookup
    attr_reader :query_params
    attr_reader :find_response
    attr_reader :request_number

    def initialize; end

    # default method using BorrowDirect::Defaults.find_item_patron_barcode
    def find(query_params, barcode = nil)
      ## failed lookup response looks like
      ## #<BorrowDirect::FindItem::Response:0x007fd34f289900 @response_hash={"Problem"=>{"ErrorCode"=>"PUBFI002", "ErrorMessage"=>"No result"}}, @auth_id="lO1ufRAj6CcG9AqOHV_kks3ozR8">
      ## good response looks like
      ## #<BorrowDirect::FindItem::Response:0x007fd353863980 @response_hash={"Available"=>true, "SearchTerm"=>"isbn=0415296633", "RequestLink"=>{"ButtonLink"=>"AddRequest", "ButtonLabel"=>"Request", "RequestMessage"=>"Select a pick-up location and click the Request button to order this item through Borrow Direct."}, "NumberOfRecords"=>1, "PickupLocation"=>[{"PickupLocationCode"=>"I", "PickupLocationDescription"=>"Architecture Library"}, {"PickupLocationCode"=>"A", "PickupLocationDescription"=>"East Asian Library"}, {"PickupLocationCode"=>"B", "PickupLocationDescription"=>"Engineering Library"}, {"PickupLocationCode"=>"C", "PickupLocationDescription"=>"Firestone Library"}, {"PickupLocationCode"=>"E", "PickupLocationDescription"=>"Lewis Library"}, {"PickupLocationCode"=>"F", "PickupLocationDescription"=>"Mendel Music Library"}, {"PickupLocationCode"=>"D", "PickupLocationDescription"=>"Plasma Physics Library"}, {"PickupLocationCode"=>"H", "PickupLocationDescription"=>"Stokes Library"}]}, @auth_id="LSGSEDkamjcoLRNPxdNsgpbCD00">

      @find_response = if barcode.nil?
                         ::BorrowDirect::FindItem.new.find(query_params)
                       else
                         ::BorrowDirect::FindItem.new(barcode).find(query_params)
                       end
    rescue ::BorrowDirect::Error => error
      @find_response = { error: error.message }
    end

    def available?
      if find_response.requestable?
        true
      else
        false
      end
    end
  end
end
