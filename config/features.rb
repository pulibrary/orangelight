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

  group :search_and_race do
    feature :highlighting,
      default: false,
      description: "When on / true, use the highlighting SOLR component to highlight search terms.  When off / false, dont highlight search terms"

    feature :search_result_form,
      default: false,
      description: "When on / true, a banner will be present to take the user to the search result form"
  end

  feature :temporary_where_to_find_it,
  default: true,
  description: "When on / true, the where to find it links will be disabled."

  feature :blacklight_hierarchy_facet,
  default: true,
  description: "When on / true, use the colon delimited field to display the classification facet, when off / false use the pipe delimited field"

  feature :blacklight_hierarchy_publication_facet,
  default: true,
  description: "When on / true, use the colon delimited field to display the place of publication facet, when off / false use the pipe delimited field"

  feature :source_language_of_translation,
  default: false,
  description: 'When on / true, show the Source Language of Translations dropdown on the advanced search page.  We need a full re-index before turning it on.'
end
