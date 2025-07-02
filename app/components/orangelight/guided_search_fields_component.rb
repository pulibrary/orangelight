# frozen_string_literal: true

# Fill in default from existing search, if present
# -- if you are using same search fields for basic
# search and advanced, will even fill in properly if existing
# search used basic search on same field present in advanced.
class Orangelight::GuidedSearchFieldsComponent < Blacklight::Component
  def label_tag_default_for(key)
    params_key = params[key]
    if params_key.present?
      params_key
    elsif params['search_field'] == key || guided_context(key)
      params['q']
    else
      param_for_field key
    end
  end

  # :reek:FeatureEnvy
  def advanced_key_value
    advanced_search_fields.map do |field|
      [field[1][:label], field[0]]
    end
  end

  # carries over original search field and original guided search fields if user switches to guided search from regular search
  def guided_field(field_num, default_val)
    search_field = params[:search_field]
    search_field_for_advanced_search = advanced_search_fields[search_field]
    return search_field_for_advanced_search.key || default_val if first_search_field_selector?(field_num) && no_advanced_search_fields_specified? && search_field && search_field_for_advanced_search
    params[field_num] || param_for_field(field_num) || default_val
  end

  # carries over original search query if user switches to guided search from regular search
  def guided_context(key)
    search_field = params[:search_field]
    first_search_field?(key) &&
      search_field && advanced_search_fields[search_field]
  end

  # carries over guided search operations if user switches back to guided search from regular search
  # rubocop:disable Naming/PredicateMethod
  def guided_radio(op_num, operator)
    op_num_from_params = params[op_num]
    if op_num_from_params
      op_num_from_params == operator
    else
      operator == 'AND'
    end
  end
  # rubocop:enable Naming/PredicateMethod

  # private

  # :reek:NilCheck
  def advanced_search_fields
    blacklight_config.search_fields.select do |_key, value|
      include_in_advanced_search = value.include_in_advanced_search
      include_in_advanced_search || include_in_advanced_search.nil?
    end
  end

  # :reek:UtilityFunction
  def first_search_field_selector?(key)
    %i[clause_0_field].include? key
  end

  def no_advanced_search_fields_specified?
    %i[clause_0_field clause_1_field clause_2_field].none? do |key|
      params[key].present?
    end
  end

  # :reek:FeatureEnvy
  def param_for_field(field_identifier)
    field_identifier_string = field_identifier.to_s
    return unless field_identifier_string.start_with? 'clause'
    components = field_identifier_string.split('_')
    params.dig(*components)
  end

  # :reek:UtilityFunction
  def first_search_field?(key)
    %i[q1 clause_0_query].include? key
  end

  delegate :blacklight_config, to: :helpers
end
