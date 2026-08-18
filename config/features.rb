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

  feature :message_display,
    default: false,
    description: "When on / true, displays the message set by the announcement rake task."

  feature :libmap_test,
    default: false,
    description: "When on / true, display the 'Find on Shelf' buttons for libraries not yet live with Libmap."

  feature :deduplication,
    default: false,
    description: "When on/true use the deduplication changes."
end
