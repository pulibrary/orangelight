# frozen_string_literal: true

# Helper methods for the advanced search form
module AdvancedHelper
  # Fill in default from existing search, if present
  # -- if you are using same search fields for basic
  # search and advanced, will even fill in properly if existing
  # search used basic search on same field present in advanced.
  def label_tag_default_for(key)
    if params[key].present?
      params[key]
    elsif params['search_field'] == key || guided_context(key)
      params['q']
    else
      param_for_field key
    end
  end

  def advanced_key_value
    key_value = []
    advanced_search_fields.each do |field|
      key_value << [field[1][:label], field[0]]
    end
    key_value
  end

  # carries over original search field and original guided search fields if user switches to guided search from regular search
  def guided_field(field_num, default_val)
    return advanced_search_fields[params[:search_field]].key || default_val if first_search_field_selector?(field_num) && no_advanced_search_fields_specified? && params[:search_field] && advanced_search_fields[params[:search_field]]
    params[field_num] || param_for_field(field_num) || default_val
  end

  # carries over original search query if user switches to guided search from regular search
  def guided_context(key)
    first_search_field?(key) &&
      params[:f1].nil? && params[:f2].nil? && params[:f3].nil? &&
      params[:search_field] && advanced_search_fields[params[:search_field]]
  end

  # carries over guided search operations if user switches back to guided search from regular search
  def guided_radio(op_num, op)
    if params[op_num]
      params[op_num] == op
    else
      op == 'AND'
    end
  end

  def generate_solr_fq
    filters.map do |solr_field, value_list|
      value_list = value_list.values if value_list.is_a?(Hash)

      "#{solr_field}:(" +
        Array(value_list).collect { |v| '"' + v.gsub('"', '\"') + '"' }.join(' OR  ') +
        ')'
    end
  end

  private

    def advanced_search_fields
      blacklight_config.search_fields.select { |_k, v| v.include_in_advanced_search || v.include_in_advanced_search.nil? }
    end

    def first_search_field_selector?(key)
      [:f1, :clause_0_field].include? key
    end

    def no_advanced_search_fields_specified?
      [:f1, :f2, :f3, :clause_0_field, :clause_1_field, :clause_2_field].none? do |key|
        params[key].present?
      end
    end

    def param_for_field(field_identifier)
      if field_identifier.to_s.start_with? 'clause'
        components = field_identifier.to_s.split('_')
        params.dig(*components)
      end
    end

    def first_search_field?(key)
      [:q1, :clause_0_query].include? key
    end
end
