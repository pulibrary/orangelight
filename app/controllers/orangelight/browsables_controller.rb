class Orangelight::BrowsablesController < ApplicationController
  before_action :set_orangelight_browsable, only: [:show]

  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
    # if rpp isn't specified default is 50
    # previous/next page links need to pass
    # manually set rpp
    if params[:rpp].nil?
      @rpp = 10
      @page_link = "?"
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
    

    unless params[:val].nil?
      search_result = params[:model].where('label < ?', params[:val]).last
      unless search_result.nil?
        @start = search_result.id
        #@prev = @start/@rpp+1      
      end
    end

    # gets last page of table's results
    if params[:model].last
      @last_id = params[:model].last.id 
    else
      @last_id = 1
    end
    
    # makes sure no next page link is shown for last page
    @is_last = (@last_id-@rpp+1) <= @start
    # makes sure valid page is displayed
    if !(@last_id-@rpp+1..@last_id).cover?(@start) && @is_last
      @start = @last_id-@rpp+1
    end


    @is_first = @start == 1

    if (@start+@rpp-1) > @last_id
      @page_last = @last_id
    else
      @page_last = @start+@rpp-1
    end

    @prev = @start - @rpp
    if @prev < 1
      @prev = 1
    end
    @next = @start + @rpp
    # @prev ||= @start/@rpp
    # @next = @start/@rpp+2
    @orangelight_browsables = params[:model].where(id: @start..(@page_last))
    @model = params[:model].name.demodulize.tableize

    if @model == 'names'
      @facet = 'author_s'
    else @model == 'subject'
      @facet = 'subject_topic_facet'
    end
        
    @list_name = params[:model].name.demodulize.titleize

  end
 
 def browse
 end
  # GET /orangelight/names/1
  # GET /orangelight/names/1.json
  def show
  end

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

