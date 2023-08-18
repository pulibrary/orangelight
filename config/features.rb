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

  feature :message_display,
    default: false,
    description: "When on / true, displays the message set by the announcement rake task."

  group :blacklight_8 do
    feature :json_query_dsl,
    description: "When on / true, use the JSON query DSL for search fields in the advanced search.  When off / false, use query params"

    feature :view_components_numismatics,
    description: "When on / true, use the built-in advanced search form for numismatics.  When off / false, use the traditional one"

    feature :view_components_advanced_search,
    description: "When on / true, use the built-in advanced search form.  When off / false, use the traditional one"

  end
end
