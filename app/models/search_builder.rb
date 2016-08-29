class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightHelper

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr,
                                   :cjk_mm, :wildcard_char_strip, :only_home_facets,
                                   :left_anchor_strip, :course_reserve_filters,
                                   :series_title_results]
end
