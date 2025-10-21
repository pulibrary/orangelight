# frozen_string_literal: true
module Requests
  class RequestablesList
    # This factory is responsible for creating a Requestable when there are too many items to load
    # in a performant way
    class TooManyItemsFactory < NoItemsFactory
      def placeholder_item_class
        TooManyItemsPlaceholderItem
      end
    end
  end
end
