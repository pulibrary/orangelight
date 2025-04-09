# frozen_string_literal: true
class GuidedSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  # self.default_processor_chain

  # Transform "clause" parameters into the Solr JSON Query DSL
  def add_adv_search_clauses(solr_parameters)
    puts('IN GUIDED SEARCH#add_adv_search_clauses')
    puts('---------------------------------------------------------------')
    return if search_state.clause_params.blank?

    defaults = { must: [], must_not: [], should: [] }
    default_op = blacklight_params[:op]&.to_sym || :must
    solr_parameters[:mm] = 1 if default_op == :should && search_state.clause_params.values.any? { |clause| }

    search_state.clause_params.each_value do |clause|
      op, query = adv_search_clause(clause, default_op)
      next unless defaults.key?(op)

      solr_parameters.append_boolean_query(op, query)
    end
  end

  # @return [Array] the first element is the query operator and the second is the value to add
  def adv_search_clause(clause, default_op)
    puts('IN GUIDED SEARCH#add_adv_search_clause')
    puts('---------------------------------------------------------------')
    op = clause[:op]&.to_sym || default_op
    field = (blacklight_config.search_fields || {})[clause[:field]] if clause[:field]

    return unless field&.clause_params && clause[:query].present?
    [op, field.clause_params.transform_values { |v| v.merge(query: clause[:query]) }]
  end

  private
    def request
      Orangelight::Solr::Request.new
    end
end
