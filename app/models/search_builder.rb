# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder
  include BlacklightHelper

  default_processor_chain.unshift(:conditionally_configure_json_query_dsl)

  self.default_processor_chain += %i[parslet_trick cleanup_boolean_operators
                                     cjk_mm wildcard_char_strip 
                                     only_home_facets prepare_left_anchor_search fancy_booleans
                                     series_title_results pul_holdings html_facets
                                     numismatics_facets numismatics_advanced
                                     adjust_mm remove_unneeded_facets]

  # mutate the solr_parameters to remove words that are
  # boolean operators, but not intended as such.
  def cleanup_boolean_operators(solr_parameters)
    transform_queries!(solr_parameters) { |query| cleaned_query(query) }
  end

  def fancy_booleans(solr_parameters)
    # byebug if solr_parameters.dig('json')
    solr_parameters.dig('json', 'query', 'bool', 'must')
    # Find phrase with OR
    phrases_with_or = solr_parameters.dig('json', 'query', 'bool', 'must')&.select do |clause|
      clause[:edismax][:query].include?('OR')
    end
    # take phrase with OR out of "must" array
    phrases_with_or&.each do |phrase|
      solr_parameters['json']['query']['bool']['must'].delete(phrase)
    end
    # split into individual phrases for each part of "should" and put in "should" array
    should_array = []
    phrases_with_or&.map do |phrase|
      sub_phrases = phrase[:edismax][:query].split(' OR ')
      sub_phrases.each do |sub_phrase|
        should_array << { edismax: { query: sub_phrase } }
      end
    end
    # create "should" clause
    solr_parameters['json']['query']['bool']['should'] = should_array if should_array.present?

    return unless solr_parameters.dig('json', 'query', 'bool', 'must') && solr_parameters.dig('json', 'query', 'bool', 'must').empty?
    solr_parameters['json']['query']['bool'].delete('must')
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

  def facets_for_advanced_search_form(solr_p)
    # Reject any facets that are meant to display on the advanced
    # search form, so that the form displays accurate counts for
    # them in its dropdowns
    advanced_search_facets = blacklight_config.advanced_search.form_solr_parameters['facet.field']
    solr_p[:fq]&.compact!
    solr_p[:fq]&.reject! do |facet_from_query|
      advanced_search_facets.any? { |facet_to_exclude| facet_from_query.include? facet_to_exclude }
    end
  end

  def only_home_facets(solr_parameters)
    return if search_parameters? || advanced_search?
    solr_parameters['facet.field'] = blacklight_config.facet_fields.select { |_, v| v[:home] }.keys
    solr_parameters['facet.pivot'] = []
  end

  ##
  # Check if we are on an advanced search page
  # @return [Boolean]
  def advanced_search?
    blacklight_params[:advanced_type] == 'advanced' ||
      search_state.controller.try(:params).try(:[], :action) == 'advanced_search' ||
      blacklight_params[:advanced_type] == 'numismatics'
  end

  ##
  # Check if any search parameters have been set
  # @return [Boolean]
  def search_parameters?
    search_query_present? || facet_query_present?
  end

  def conditionally_configure_json_query_dsl(_solr_parameters)
    advanced_fields = %w[all_fields title author subject left_anchor publisher in_series notes series_title isbn issn]
    add_edismax(advanced_fields:)
  end

  def adjust_mm(solr_parameters)
    # If the user is attempting a boolean OR query,
    # for example: activism OR "social justice"
    # don't want to cancel out the boolean OR with
    # an mm configuration that requires all the clauses
    # to be in the document
    return unless blacklight_params[:q].to_s.split.include? 'OR'
    solr_parameters['mm'] = 0
  end

  def includes_written_boolean?
    if advanced_search? && search_query_present?
      json_query_dsl_clauses&.any? { |clause| clause&.dig('query')&.include?('OR') }
    else
      blacklight_params[:q].to_s.split.include? 'OR'
    end
  end

  # When the user is viewing the values of a specific facet
  # by clicking the "more" link in a facet, solr doesn't
  # need to perform expensive calculations related to other
  # facets that the user is not displaying
  # :reek:FeatureEnvy
  def remove_unneeded_facets(solr_parameters)
    return unless facet
    remove_unneeded_stats(solr_parameters)
    solr_parameters.delete('facet.pivot') unless solr_parameters['facet.pivot']&.split(',')&.include? facet
    solr_parameters.delete('facet.query') unless solr_parameters['facet.query']&.any? { |query| query.partition(':').first == facet }
  end

  def wildcard_char_strip(solr_parameters)
    transform_queries!(solr_parameters) { |query| query.delete('?') }
  end

  private

    def search_query_present?
      !blacklight_params[:q].nil? || json_query_dsl_clauses&.any? { |clause| clause.dig('query')&.present? }
    end

    def facet_query_present?
      blacklight_params[:f].present? || blacklight_params[:action] == 'facet'
    end

    def json_query_dsl_clauses
      blacklight_params.dig('clause')&.values
    end

    def q_param_needs_boolean_cleanup(solr_parameters)
      solr_parameters[:q].present? &&
        cleaned_query(solr_parameters[:q]) == solr_parameters[:q]
    end

    def add_edismax(advanced_fields:)
      advanced_fields.each do |field|
        solr_params = blacklight_config.search_fields[field]['solr_parameters']
        edismax = solr_params.present? ? solr_params.dup : {}
        blacklight_config.search_fields[field]['clause_params'] = { edismax: }
      end
    end

    # :reek:FeatureEnvy
    def remove_unneeded_stats(solr_parameters)
      return if solr_parameters['stats.field'].to_a.include? facet
      solr_parameters.delete('stats')
      solr_parameters.delete('stats.field')
    end

    # :reek:DuplicateMethodCall
    # :reek:MissingSafeMethod
    # :reek:UtilityFunction
    def transform_queries!(solr_parameters)
      solr_parameters[:q] = yield solr_parameters[:q] if solr_parameters[:q]
      solr_parameters.dig('json', 'query', 'bool', 'must')&.map! do |search_element|
        search_element[:edismax][:query] = yield search_element[:edismax][:query]
        search_element
      end
    end

    def cleaned_query(query)
      return query if query.nil?
      query.gsub(/([A-Z]) (NOT|OR|AND) ([A-Z])/) do
        "#{Regexp.last_match(1)} #{Regexp.last_match(2).downcase} #{Regexp.last_match(3)}"
      end
    end
end
