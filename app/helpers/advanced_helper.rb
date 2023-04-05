# frozen_string_literal: true

# Helper methods for the advanced search form
module AdvancedHelper
  # include BlacklightAdvancedSearch::AdvancedHelperBehavior

  def search_fields_for_advanced_search
    @search_fields_for_advanced_search ||= blacklight_config.search_fields.select { |_k, v| v.include_in_advanced_search || v.include_in_advanced_search.nil? }
  end

  # Current params without fields that will be over-written by adv. search,
  # or other fields we don't want.
  def advanced_search_context
    my_params = search_state.params_for_search.except :page, :f_inclusive, :q, :search_field, :op, :index, :sort

    my_params.except!(*search_fields_for_advanced_search.map { |_key, field_def| field_def[:key] })
  end

  # Fill in default from existing search, if present
  # -- if you are using same search fields for basic
  # search and advanced, will even fill in properly if existing
  # search used basic search on same field present in advanced.
  def label_tag_default_for(key)
    if params[key].present?
      params[key]
    elsif params['search_field'] == key || guided_context(key)
      params['q']
    end
  end

  def advanced_key_value
    key_value = []
    search_fields_for_advanced_search.each do |field|
      key_value << [field[1][:label], field[0]]
    end
    key_value
  end

  # carries over original search field and original guided search fields if user switches to guided search from regular search
  def guided_field(field_num, default_val)
    return search_fields_for_advanced_search[params[:search_field]].key || default_val if field_num == :f1 && params[:f1].nil? && params[:f2].nil? && params[:f3].nil? && params[:search_field] && search_fields_for_advanced_search[params[:search_field]]
    params[field_num] || default_val
  end

  # carries over original search query if user switches to guided search from regular search
  def guided_context(key)
    key == :q1 && params[:f1].nil? && params[:f2].nil? && params[:f3].nil? &&
      params[:search_field] && search_fields_for_advanced_search[params[:search_field]]
  end

  # carries over guided search operations if user switches back to guided search from regular search
  def guided_radio(op_num, op)
    if params[op_num]
      params[op_num] == op
    else
      op == 'AND'
    end
  end

  def location_codes_by_lib(facet_items)
    locations = {}
    non_code_items = []
    facet_items.each do |item|
      holding_loc = Bibdata.holding_locations[item.value]
      holding_loc.nil? ? non_code_items << item : add_holding_loc(item, holding_loc, locations)
    end
    library_facet_values(non_code_items, locations)
    locations.sort.to_h
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

    def add_holding_loc(item, holding_loc, locations)
      library = holding_loc['library']['label']
      add_library(library, locations)
      locations[library]['codes'] << item
      add_scsb_loc(item, holding_loc, locations)
    end

    def add_scsb_loc(item, holding_loc, locations)
      unless holding_loc['holding_library'].nil?
        library = holding_loc['holding_library']['label']
        add_library(library, locations)
        locations[library]['recap_codes'] << item
      end
    end

    def add_library(library, locations)
      locations[library] = { 'codes' => [], 'recap_codes' => [] } if locations[library].nil?
    end

    def library_facet_values(non_code_items, locations)
      non_code_items.each do |item|
        locations[item.value]['item'] = item if locations.key?(item.value)
      end
    end
end
