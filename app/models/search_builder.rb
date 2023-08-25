# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightHelper

  default_processor_chain.unshift(:conditionally_configure_json_query_dsl)

  self.default_processor_chain += %i[parslet_trick cleanup_boolean_operators add_advanced_search_to_solr
                                     cjk_mm wildcard_char_strip excessive_paging_error
                                     only_home_facets left_anchor_escape_whitespace
                                     series_title_results pul_holdings html_facets
                                     numismatics_facets numismatics_advanced]

  # mutate the solr_parameters to remove words that are
  # boolean operators, but not intended as such.
  def cleanup_boolean_operators(solr_parameters)
    return add_advanced_parse_q_to_solr(solr_parameters) if run_advanced_parse?(solr_parameters)
    solr_parameters[:q] = cleaned_query(solr_parameters[:q])
    return solr_parameters unless using_json_query_dsl(solr_parameters)

    solr_parameters.dig('json', 'query', 'bool', 'must').map! do |search_element|
      search_element[:edismax][:query] = cleaned_query(search_element[:edismax][:query])
      search_element
    end
  end

  # Blacklight uses Parslet https://rubygems.org/gems/parslet/versions/2.0.0 to parse the user query
  # and unfortunately Parslet gets confused when the user's query ends with "()". Here we tweak the
  # query to prevent the error and let the query to be parsed as if the ending "()" was not present.
  # Notice that we must update the value in `blacklight_params[:q]`
  def parslet_trick(_solr_parameters)
    return unless blacklight_params[:q].is_a?(String)
    return unless blacklight_params[:q].strip.end_with?("()")
    blacklight_params[:q] = blacklight_params[:q].strip.gsub("()", "")
  end

  # Only search for coin records when querying with the numismatics advanced search
  def numismatics_advanced(solr_parameters)
    return unless blacklight_params[:advanced_type] == 'numismatics'
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "format:Coin"
  end

  def numismatics_facets(solr_parameters)
    return unless blacklight_params[:action] == 'numismatics'
    blacklight_config.advanced_search[:form_solr_parameters]['facet.field'] = blacklight_config.numismatics_search['facet_fields']
    solr_parameters['facet.field'] = blacklight_config.numismatics_search['facet_fields']
  end

  def cleaned_query(query)
    return query if query.nil?
    query.gsub(/([A-Z]) (NOT|OR|AND) ([A-Z])/) do
      "#{Regexp.last_match(1)} #{Regexp.last_match(2).downcase} #{Regexp.last_match(3)}"
    end
  end

  def run_advanced_parse?(solr_parameters)
    blacklight_params[:q].blank? ||
      !blacklight_params[:q].respond_to?(:to_str) ||
      q_param_needs_boolean_cleanup(solr_parameters)
  end

  def facets_for_advanced_search_form(solr_p)
    # Reject any facets that are meant to display on the advanced
    # search form, so that the form displays accurate counts for
    # them in its dropdowns
    advanced_search_facets = blacklight_config.advanced_search.form_solr_parameters['facet.field']
    solr_p[:fq]&.compact!
    solr_p[:fq]&.reject! do |facet_from_query|
      advanced_search_facets.any? { |facet_to_exclude| facet_from_query.include? facet_to_exclude }
    end
    super
  end

  def only_home_facets(solr_parameters)
    return if search_parameters?
    solr_parameters['facet.field'] = blacklight_config.facet_fields.select { |_, v| v[:home] }.keys
    solr_parameters['facet.pivot'] = []
  end

  # Determines whether or not the user is requesting an excessively high page of results
  # @param [ActionController::Parameters] params
  # @return [Boolean]
  def excessive_paging_error(_solr_parameters)
    raise ActionController::BadRequest if excessive_paging?
  end

  # Determines whether or not the user is requesting an excessively high page of results
  # @return [Boolean]
  def excessive_paging?
    page = blacklight_params[:page].to_i || 0
    return false if page <= 1
    return false if search_parameters? && page < 1000
    true
  end

  ##
  # Check if any search parameters have been set
  # @return [Boolean]
  def search_parameters?
    !blacklight_params[:q].nil? || blacklight_params[:f].present? ||
      blacklight_params[:search_field] == 'advanced'
  end

  def conditionally_configure_json_query_dsl(_solr_parameters)
    advanced_fields = %w[title author subject left_anchor publisher in_series notes series_title isbn issn]
    if Flipflop.json_query_dsl?
      blacklight_config.search_fields['all_fields']['clause_params'] = {
        edismax: {}
      }
      advanced_fields.each do |field|
        blacklight_config.search_fields[field]['clause_params'] = {
          edismax: blacklight_config.search_fields[field]['solr_parameters'].dup
        }
      end
    else
      blacklight_config.search_fields['all_fields'].delete('clause_params')
      advanced_fields.each do |field|
        blacklight_config.search_fields[field].delete('clause_params')
      end
    end
  end

  private

    def q_param_needs_boolean_cleanup(solr_parameters)
      solr_parameters[:q].present? &&
        cleaned_query(solr_parameters[:q]) == solr_parameters[:q]
    end

    def using_json_query_dsl(solr_parameters)
      solr_parameters.fetch('json', nil)&.fetch('query', nil)&.fetch('bool', nil)&.fetch('must', nil)&.present?
    end
end
