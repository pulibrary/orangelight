# frozen_string_literal: true

module Requests
  # This class is responsible for behaving as an item in cases where there
  # are far too many items to load
  class TooManyItemsPlaceholderItem < NullItem
    def status
      # Don't display a status, since we can't tell what the status actually is
      # without loading hundreds and hundreds of items
    end
  end
end
