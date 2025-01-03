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

  group :blacklight_8 do
    feature :view_components_advanced_search,
    description: "When on / true, use the built-in advanced search form.  When off / false, use the traditional one"
  end

  group :search_and_race do
    feature :multi_algorithm,
      default: false,
      description: "When on / true, the user will have the ability to choose between search algorithms.  When off / false, no choice is available"

    feature :highlighting,
      default: false,
      description: "When on / true, use the highlighting SOLR component to highlight search terms.  When off / false, dont highlight search terms"

    feature :search_result_form,
      default: false,
      description: "When on / true, a banner will be present to take the user to the search result form"
  end

  feature :enumeration_backwards_compatibility,
    default: true,
    description: "When on / true, use the enumeration/chronology data from both the new item description field and the legacy item enumeration field.  When false, only look at the new description field.  We can change this value to false (and remove the feature) after the next full re-index."

  feature :blacklight_hierarchy_facet,
  default: false,
  description: "When on / true, use the blacklight hierarchy gem to display the classification facet"
end
