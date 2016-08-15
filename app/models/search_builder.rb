class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightHelper

  self.default_processor_chain += [:cjk_mm, :wildcard_char_strip, :only_home_facets,
                                   :only_advanced_facets, :left_anchor_strip,
                                   :course_reserve_filters, :series_title_results]
end
