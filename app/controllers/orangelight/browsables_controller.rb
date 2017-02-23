
class Orangelight::BrowsablesController < ApplicationController
  # before_action :set_orangelight_browsable, only: [:show]

  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
    # if rpp isn't specified default is 50
    # previous/next page links need to pass
    # manually set rpp

    @model = params[:model].name.demodulize.tableize
    if params[:rpp].nil?
      @rpp = 50
      @page_link = '?'
    else
      @rpp = params[:rpp].to_i
      @page_link = "?rpp=#{@rpp}&"
    end
    # if params[:page].nil?
    #   @page=1
    # else
    #   @page = params[:page].to_i
    # end

    # @start gets the id of the first entry to display on page
    # specific ids are given based on search results
    @start = params[:start].nil? ? 1 : params[:start].to_i

    unless params[:q].nil?
      search_term = if @model == 'call_numbers'
                      StringFunctions.cn_normalize(params[:q])
                    else
                      params[:q].normalize_em
                    end
      search_result = params[:model].where('sort <= ?', search_term).last
      unless search_result.nil?
        @search_result = search_result.label
        @search_term = search_term
        @exact_match = search_term == search_result.sort
        @match = search_result.id
        @start = search_result.id - 1
        @start -= 1 if @exact_match
        @start = 1 if @start < 1
        @query = params[:q]
      end
    end

    # gets last page of table's results
    @last_id = if params[:model].last
                 params[:model].last.id
               else
                 1
               end

    # makes sure no next page link is shown for last page
    @is_last = (@last_id - @rpp + 1) <= @start
    # makes sure valid page is displayed
    if !(@last_id - @rpp + 1..@last_id).cover?(@start) && @is_last
      @start = @last_id - @rpp + 1
      @start = 1 if @start < 1 # catch for start ids higher than last id
    end

    @is_first = @start == 1

    @page_last = if (@start + @rpp - 1) > @last_id
                   @last_id
                 else
                   @start + @rpp - 1
                 end

    @prev = @start - @rpp
    @prev = 1 if @prev < 1
    @next = @start + @rpp
    @orangelight_browsables = params[:model].where(id: @start..@page_last)

    if @model == 'names'
      @facet = 'author_s'
    elsif @model == 'subjects'
      @facet = 'subject_facet'
    elsif @model == 'name_titles'
      @facet = 'name_title_browse_s'
    end

    @list_name = params[:model].name.demodulize.tableize.humanize
    @list_name = 'author-title headings' if @list_name == 'Name titles'

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orangelight_browsables }
    end
  end

  # GET /orangelight/names/1
  # GET /orangelight/names/1.json
  # def show
  # end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_orangelight_browsable
      @orangelight_browsable = params[:model].find(params[:id]) if params[:model]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orangelight_browsable_params
      params.require(:orangelight_browsable).permit(:model, :id)
    end
end
