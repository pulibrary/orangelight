# frozen_string_literal: true
Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :active_record
  strategy :default

  # Other strategies:
  #
  # strategy :cookie
  # strategy :sequel
  # strategy :redis
  #
  # strategy :query_string
  # strategy :session
  #
  # strategy :my_strategy do |feature|
  #   # ... your custom code here; return true/false/nil.
  # end

  # Declare your features, e.g:
  #
  # feature :test_header,
  #   default: false,
  #   description: "Display a test header to show if flipflop is working."

  feature :reshare_for_borrow_direct,
    default: false,
    description: "When on / true, uses the new ReShare provider for BorrowDirect. When off / false, uses the older Relais provider for BorrowDirect."

  feature :firestone_locator,
    default: true,
    description: "When on / true, uses the old locator service for Firestone. When off / false uses the new Stackmap service for Firestone."
end
