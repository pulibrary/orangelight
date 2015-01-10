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
      # operation = 'op2'
      # @keyword_op = []
      # until @params[operation].nil?
      #   @keyword_op << @params[operation]
      #   operation = operation.next
      # end
      @keyword_op = []
      unless @params[:q1].blank? || @params[:q2].blank? || @params[:op2] == "NOT"
        @keyword_op << @params[:op2] if (@params[:f1] != @params[:f2])
      end
      unless @params[:q3].blank? || @params[:op3] == "NOT"
        @keyword_op << @params[:op3] if @params[:f2] != @params[:f3]
      end 
      return @keyword_op
    end

    def keyword_queries
      unless(@keyword_queries)
        @keyword_queries = {}

        return @keyword_queries unless @params[:search_field] == ::AdvancedController.blacklight_config.advanced_search[:url_key]


        # sfield = 'f1'
        # aquery = 'q1'
        # until @params[sfield].nil?
        #   if @keyword_queries[@params[sfield]]
        #     @keyword_queries[@params[sfield]] << @params[aquery.to_sym]
        #   else
        #     @keyword_queries[@params[sfield]] = [ @params[aquery.to_sym] ]
        #   end
        #   sfield = sfield.next
        #   aquery = aquery.next
        # end
        # @keyword_queries[@params[:f1]] = @params[:q1] unless @params[:q1].blank?
        # @keyword_queries[@params[:f2]] = @params[:q2] unless @params[:q2].blank?
        # @keyword_queries[@params[:f3]] = @params[:q3] unless @params[:q3].blank? 
        been_combined = false
        @keyword_queries[@params[:f1]] = @params[:q1] unless @params[:q1].blank?
        unless @params[:q2].blank?
          if @keyword_queries.has_key?(@params[:f2])
            @keyword_queries[@params[:f2]] = "(#{@keyword_queries[@params[:f2]]}) " + @params[:op2] + " (#{@params[:q2]})"
            been_combined = true
          elsif @params[:op2] == "NOT"
            @keyword_queries[@params[:f2]] = "NOT " + @params[:q2]
          else
            @keyword_queries[@params[:f2]] = @params[:q2]
          end
        end
        unless @params[:q3].blank?
          if @keyword_queries.has_key?(@params[:f3])
            @keyword_queries[@params[:f3]] = "(#{@keyword_queries[@params[:f3]]})" unless been_combined
            @keyword_queries[@params[:f3]] = "#{@keyword_queries[@params[:f3]]} " + @params[:op3] + " (#{@params[:q3]})"
          elsif @params[:op3] == "NOT"
            @keyword_queries[@params[:f3]] = "NOT " + @params[:q3]            
          else
            @keyword_queries[@params[:f3]] = @params[:q3]
          end
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
    keyword_queries.each do |field, query| 
      queries << ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query( local_param_hash(field, config) )
      queries << ops.shift
    end
    queries.join(' ')
  end
end

module BlacklightAdvancedSearch::CatalogHelperOverride

  def remove_advanced_keyword_query(field, my_params = params)
    my_params = my_params.dup
    my_params.delete(field)
    return my_params
  end
end


module BlacklightAdvancedSearch::RenderConstraintsOverride

  #Over-ride of Blacklight method, provide advanced constraints if needed,
  # otherwise call super. Existence of an @advanced_query instance variable
  # is our trigger that we're in advanced mode.
  def render_constraints_query(my_params = params)
    if (@advanced_query.nil? || @advanced_query.keyword_queries.empty? )
      return super(my_params)
    else
      content = []
      @advanced_query.keyword_queries.each_pair do |field, query|
        label = search_field_def_for_key(field)[:label]
        content << render_constraint_element(
          label, query,
          :remove =>
            catalog_index_path(remove_advanced_keyword_query(field,my_params))
        )
      end
      if (@advanced_query.keyword_op == "OR" &&
          @advanced_query.keyword_queries.length > 1)
        content.unshift content_tag(:span, "Any of:", class:'operator')
        content_tag :span, class: "inclusive_or appliedFilter well" do
          safe_join(content.flatten, "\n")
        end
      else
        safe_join(content.flatten, "\n")    
      end
    end
  end
end