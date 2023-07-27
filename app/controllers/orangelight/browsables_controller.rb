# frozen_string_literal: true

class Orangelight::BrowsablesController < ApplicationController
  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
    # if rpp isn't specified default is 50
    # if rpp has values other than 10, 25, 50, 100 then set it to 50
    # previous/next page links need to pass
    # manually set rpp

    assign_values

    # makes sure valid page is displayed
    if !(@last_id - @rpp + 1..@last_id).cover?(@start) && @is_last
      @start = @last_id - @rpp + 1
      @start = 1 if @start < 1 # catch for start ids higher than last id
    end

    assign_pagination_values

    @facet = facet
    @list_name = list_name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orangelight_browsables }
    end
  end

  private

    def assign_values
      @model = model_table_name
      @rpp = rpp
      @page_link = page_link

      # @start gets the id of the first entry to display on page
      # specific ids are given based on search results
      @start = first_model_id

      populate_search_results

      # gets last page of table's results
      @last_id = last_model_id

      # makes sure no next page link is shown for last page
      @is_last = (@last_id - @rpp + 1) <= @start
    end

    def rpp
      if rpp_param.nil?
        50
      else
        validate_rpp(requested_rpp)
      end
    end

    def page_link
      if rpp_param.nil?
        '?'
      else
        size = validate_rpp(requested_rpp)
        "?rpp=#{size}&"
      end
    end

    def validate_rpp(size)
      rpp_range = [10, 25, 50, 100]
      if rpp_range.include? size
        size
      else
        50
      end
    end

    def populate_search_results
      return if query_param.nil?

      search_result = model_param.where('sort <= ?', search_term).order('sort').last

      return if search_result.nil?

      populate_search_params(search_result)
    end

    def populate_search_params(search_result)
      @search_result = search_result.label
      @search_term = search_term
      @exact_match = search_term == search_result.sort
      @match = search_result.id
      @start = search_result.id - 1
      @start -= 1 if @exact_match
      @start = 1 if @start < 1
      @query = query_param
    end

    def assign_pagination_values
      @is_first = @start == 1

      @page_last = if (@start + @rpp - 1) > @last_id
                     @last_id
                   else
                     @start + @rpp - 1
                   end

      @prev = @start - @rpp
      @prev = 1 if @prev < 1
      @next = @start + @rpp

      @orangelight_browsables = model_param.where(id: @start..@page_last)
    end

    def facet
      if browsing_names?
        'author_s'
      elsif browsing_subjects?
        'subject_facet'
      elsif browsing_titles?
        'name_title_browse_s'
      end
    end

    # Retrieve the Model mapped to the request parameter
    # @return [Class]
    def model_param
      params[:model]
    end

    # Generates the name of the table mapped to the model in the request
    # @return [String]
    def model_table_name
      model_name = model_param.name
      model_class = model_name.demodulize
      model_class.tableize
    end

    # Determines whether or not the client is requesting to browse call numbers
    # @return [Boolean]
    def browsing_call_numbers?
      model_table_name == 'call_numbers'
    end

    # Determines whether or not the client is requesting to browse names
    # @return [Boolean]
    def browsing_names?
      model_table_name == 'names'
    end

    # Determines whether or not the client is requesting to browse subjects
    # @return [Boolean]
    def browsing_subjects?
      model_table_name == 'subjects'
    end

    # Determines whether or not the client is requesting to browse titles
    # @return [Boolean]
    def browsing_titles?
      model_table_name == 'name_titles'
    end

    # Generates the name of the list (based upon the model for the request)
    # @return [String]
    def list_name
      value = model_table_name.humanize
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
    def first_model_id
      return 1 if start_param.nil?
      start_param.to_i
    end

    # Normalizes the query transmitted by the client
    # @return [String]
    def search_term
      return StringFunctions.cn_normalize(query_param) if browsing_call_numbers?

      query_param.normalize_em
    end

    # Retrieves the ID of the last object for this request
    # @return [Integer]
    def last_model_id
      return model_param.last.id if model_param.last
      1
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

    # Use callbacks to share common setup or constraints between actions.
    def set_orangelight_browsable
      @orangelight_browsable = model_param.find(id_param) if model_param
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orangelight_browsable_params
      params.require(:orangelight_browsable).permit(:model, :id)
    end
end
