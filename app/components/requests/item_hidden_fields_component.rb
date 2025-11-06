# frozen_string_literal: true
module Requests
  class ItemHiddenFieldsComponent < ViewComponent::Base
    def initialize(requestable)
      @requestable = requestable
    end

      private

        attr_reader :requestable

        delegate :item, :partner_holding?, to: :requestable
        delegate :barcode, :enum_value, to: :item

        def request_id
          requestable.preferred_request_id
        end

        def item_id
          item['id']
        end
  end
end
