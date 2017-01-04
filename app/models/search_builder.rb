class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightHelper

  self.default_processor_chain += [:cleanup_boolean_operators, :add_advanced_search_to_solr,
                                   :cjk_mm, :wildcard_char_strip, :only_home_facets,
                                   :left_anchor_strip, :course_reserve_filters,
                                   :series_title_results]

  def cleanup_boolean_operators(solr_parameters)
    return add_advanced_parse_q_to_solr(solr_parameters) if run_advanced_parse?(solr_parameters)
    solr_parameters[:q] = cleaned_query(solr_parameters[:q])
  end

  def cleaned_query(query)
    query.gsub(/([A-Z]) (NOT|OR|AND) ([A-Z])/) do
      "#{Regexp.last_match(1)} #{Regexp.last_match(2).downcase} #{Regexp.last_match(3)}"
    end
  end

  def run_advanced_parse?(solr_parameters)
    blacklight_params[:q].blank? ||
      !blacklight_params[:q].respond_to?(:to_str) ||
      cleaned_query(solr_parameters[:q]) == solr_parameters[:q]
  end
end
