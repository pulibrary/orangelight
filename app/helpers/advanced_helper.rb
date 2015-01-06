# Helper methods for the advanced search form
module AdvancedHelper

  # Fill in default from existing search, if present
  # -- if you are using same search fields for basic
  # search and advanced, will even fill in properly if existing
  # search used basic search on same field present in advanced.
  def label_tag_default_for(key)
    if (! params[key].blank?)
      return params[key]
    elsif params["search_field"] == key
      return params["q"]
    else
      return nil
    end
  end

  # Is facet value in adv facet search results?
  def facet_value_checked?(field, value)
    BlacklightAdvancedSearch::QueryParser.new(params, blacklight_config).filters_include_value?(field, value)
  end

  def select_menu_for_field_operator
    options = {
      t('blacklight_advanced_search.all') => 'AND',
      t('blacklight_advanced_search.any') => 'OR'
    }.sort

    return select_tag(:op, options_for_select(options,params[:op]), :class => 'input-small')
  end

  # Current params without fields that will be over-written by adv. search,
  # or other fields we don't want.
  def advanced_search_context
    my_params = params.except :page, :commit, :f_inclusive, :q, :search_field, :op, :action, :index, :sort, :controller, :utf8

    my_params.except! *search_fields_for_advanced_search.map { |key, field_def| field_def[:key] }
  end

  def search_fields_for_advanced_search
    @search_fields_for_advanced_search ||= begin
      blacklight_config.search_fields.select { |k,v| v.include_in_advanced_search or v.include_in_advanced_search.nil? }
    end
  end

  def advanced_labels
    labels = []
    search_fields_for_advanced_search.each do |field|
      labels << field[1][:label] 
    end
    labels
  end

  def advanced_key_value
    key_value = []
    search_fields_for_advanced_search.each do |field|
      key_value << [field[1][:label], field[0]]
    end
    key_value    
  end

end

module BlacklightAdvancedSearch
  class QueryParser

    def keyword_op
      operation = 'op2'
      @keyword_op = []
      until @params[operation].nil?
        @keyword_op << @params[operation]
        operation = operation.next
      end
      return @keyword_op
    end

    def keyword_queries
      unless(@keyword_queries)
        @keyword_queries = {}

        return @keyword_queries unless @params[:search_field] == ::AdvancedController.blacklight_config.advanced_search[:url_key]


        sfield = 'f1'
        aquery = 'q1'
        until @params[sfield].nil?
          if @keyword_queries[@params[sfield]]
            @keyword_queries[@params[sfield]] << @params[aquery.to_sym]
          else
            @keyword_queries[@params[sfield]] = [ @params[aquery.to_sym] ]
          end
          sfield = sfield.next
          aquery = aquery.next
        end
      end

      return @keyword_queries
    end
  end
end

module BlacklightAdvancedSearch::ParsingNestingParser
  
  def process_query(params,config)
    queries = []
    ops = keyword_op
    keyword_queries.each do |field, multiquery| 
      multiquery.each do |query|
        if query == ''
          multiquery.delete_at(0)
          ops.shift
        else
          queries << ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query( local_param_hash(field, config) )
          queries << ops.shift unless ops.nil?
        end
      end
      if keyword_queries[field] == []
        keyword_queries.delete(field)
      else
        keyword_queries[field] = multiquery.join(' | ')
      end
    end
    queries.join(' ')
  end
end
