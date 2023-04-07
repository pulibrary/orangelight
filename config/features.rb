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

  feature :firestone_locator,
    default: true,
    description: "When on / true, uses the old locator service for Firestone. When off / false uses the new Stackmap service for Firestone."

  feature :harmful_content_feedback,
    default: false,
    description: "When on / true, displays the Harmful Content Feedback bar."

  feature :new_action_note_display,
    default: false,
    description: "When on / true, displays the new JSON-formatted action notes, including links. When off, only displays PULFA action notes as plain text."
end
