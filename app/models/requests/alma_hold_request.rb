module Requests
  class AlmaHoldRequest < Alma::ItemRequest
    def additional_validation!(args); end
  end
end
