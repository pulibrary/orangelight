# frozen_string_literal: true

class Orangelight::BrowsablesController < ApplicationController
  def update_facet
    if browsing_names?
      @facet = 'author_s'
    elsif browsing_subjects?
      @facet = 'subject_facet'
    elsif browsing_titles?
      @facet = 'name_title_browse_s'
    end
  end

  # All of this needs to be restructured into a QueryService Class
  def connection
    Orangelight.browse_lists_index.connection
  end

  def odm_class
    return CallNumberDocument if browsing_call_numbers?

    BrowseListDocument
  end

  def query_response_documents(query_response)
    query_response["response"]["docs"].map { |doc| odm_class.new(doc) }
  end

  ## The queries
  def solr_default_params
    {
      sort: solr_default_sort,
      fl: solr_default_fields,
      rows: 100_000_0
    }
  end

  def solr_model_query(model)
    "model_s:#{model}"
  end

  def solr_default_fields
    "id,model_s,index_i,normalized_sort,direction_s,count_i,title_s,author_s,date_s,bibid_s,holding_id_s,location_s,scheme_s,normalized_s"
  end

  def solr_default_sort
    "index_i asc,normalized_sort asc" # The last-added Document should be last
  end

  # Generate the query for finding documents by model within an inclusive range of indices
  # @return [Hash]
  def find_range_by_model_query(model, start, last)
    solr_query = solr_model_query(model)
    range_parameters = {
      q: solr_query
    }
    range_parameters[:fq] = "index_i:[#{start} TO #{last}]" unless start.nil? && last.nil?

    solr_default_params.merge(range_parameters)
  end

  def find_range_by_model(model:, start:, last:)
    query = find_range_by_model_query(model, start, last)
    query_response = connection.get('select', params: query)
    query_response_documents(query_response)
  end

  def find_by_model_query(model)
    solr_default_params.merge(
      q: solr_model_query(model)
    )
  end

  def find_by_model(model:)
    @documents_by_model = {} if @documents_by_model.nil?

    @documents_by_model[model] ||= begin
                                     query = find_by_model_query(model)
                                     query_response = connection.get('select', params: query)
                                     query_response_documents(query_response)
                                   end
  end

  def find_sorted_by_model_query(model, search_term)
    solr_query = solr_model_query(model)

    solr_default_params.merge(
      q: solr_query,
      fq: "normalized_sort:[* TO \"#{search_term}\"]",
      sort: "normalized_sort asc"
    )
  end

  def find_sorted_by_model(model:, sort_by:)
    query = find_sorted_by_model_query(model, sort_by)
    query_response = connection.get('select', params: query)
    query_response_documents(query_response)
  end

  # State handling methods for the controller
  ## Normalizes the query transmitted by the client
  # @return [String]
  def search_term
    return StringFunctions.cn_normalize(query_param) if browsing_call_numbers?

    query_param.normalize_em
  end

  def update_search_state
    return if query_param.nil?

    documents = find_sorted_by_model(model: model_param, sort_by: search_term)
    search_result = documents.last

    return if search_result.nil?

    @search_result = search_result.label
    @search_term = search_term
    @exact_match = search_term == search_result.sort
    @match = search_result.index

    # This should be handled within a method for handling pagination state
    @start = search_result.index - 1
    @start -= 1 if @exact_match
    @start = 1 if @start < 1

    @query = query_param
  end

  # Updates the results-per-page variable using the request parameters
  def update_rpp
    # if rpp isn't specified default is 50
    # if rpp has values other than 10, 25, 50, 100 then set it to 50
    # previous/next page links need to pass
    # manually set rpp

    if rpp_param.nil?
      @rpp = 50
    else
      rpp_range = [10, 25, 50, 100]
      @rpp = if rpp_range.include?(requested_rpp)
               requested_rpp
             else
               50
             end
    end
  end

  # Updates the page link using the request parameters
  def update_page_link
    return @page_link = '?' if rpp_param.nil?

    @page_link = "?rpp=#{@rpp}&"
  end

  def update_pagination_state
    # gets last page of table's results
    @last_id = last_model_index

    # Ensures that no "next page" link is rendered for cases without results
    @is_last = true
    return if @last_id.nil?

    @start = first_model_index
    # @start gets the id of the first entry to display on page
    # specific ids are given based on search results

    # makes sure no next page link is shown for last page
    @is_last = (@last_id - @rpp + 1) <= @start

    # Ensures that a valid start page value is set
    page_id_range = (@last_id - @rpp) + 1..@last_id
    @start = @last_id - @rpp + 1 if @is_last && !page_id_range.cover?(@start)
    @start = 0 if @start <= 1 # catch for start ids higher than last id

    @is_first = @start.zero?

    @page_last = if (@start + @rpp - 1) > @last_id
                   @last_id
                 else
                   @start + @rpp - 1
                 end

    @prev = @start - @rpp
    @prev = 1 if @prev < 1
    @next = @start + @rpp
  end

  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
    @model = model_name

    # The Call Number documents follow this structure:
    update_rpp
    update_page_link

    update_search_state
    update_pagination_state
    @orangelight_browsables = find_range_by_model(model: model_name, start: @start, last: @page_last)

    update_facet
    @list_name = list_name

    respond_to do |format|
      format.html
      format.json { render json: @orangelight_browsables }
    end
  end

  private

    # Retrieve the Model mapped to the request parameter
    # @return [Class]
    def model_param
      params[:model]
    end

    # Generates the name of the table mapped to the model in the request
    # @return [String]
    def model_name
      model_param
    end

    # Determines whether or not the client is requesting to browse call numbers
    # @return [Boolean]
    def browsing_call_numbers?
      model_name == 'call_numbers'
    end

    # Determines whether or not the client is requesting to browse names
    # @return [Boolean]
    def browsing_names?
      model_name == 'names'
    end

    # Determines whether or not the client is requesting to browse subjects
    # @return [Boolean]
    def browsing_subjects?
      model_name == 'subjects'
    end

    # Determines whether or not the client is requesting to browse titles
    # @return [Boolean]
    def browsing_titles?
      model_name == 'name_titles'
    end

    # Generates the name of the list (based upon the model for the request)
    # @return [String]
    def list_name
      value = model_name.humanize
      return 'author-title headings' if value == 'Name titles'
      value
    end

    # Retrieves the ID requested by the client
    # @return [String]
    def id_param
      params[:id]
    end

    # Retrieves the query transmitted by the client
    # @return [String]
    def query_param
      params[:q]
    end

    # Retrieves the ID for the first object requested by the client
    # @return [String]
    def start_param
      params[:start]
    end

    # Retrieves the ID of the first object for this request
    # @return [Integer]
    def first_document
      return nil if model_param.nil?

      documents = find_by_model(model: model_name)
      @first_document ||= documents.first
    end

    # @todo is this needed still?
    def first_model_id
      first_document&.id
    end

    def first_model_index
      return start_param.to_i if start_param

      first_document&.index
    end

    def last_document
      return nil if model_param.nil?

      documents = find_by_model(model: model_name)
      @last_document ||= documents.last
    end

    def last_model_index
      last_document&.index
    end

    # @todo is this still needed?
    def last_model_id
      last_document&.id
    end

    # Retrieves the requested rows per page (rpp) from the client
    # @return [String]
    def rpp_param
      params[:rpp]
    end

    # Generates the requested rows per page as an Integer
    # @return [Integer]
    def requested_rpp
      rpp_param.to_i
    end
end
