class Orangelight::BrowsablesController < ApplicationController
  before_action :set_orangelight_browsable, only: [:show]

  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
    # if limit isn't specified default is 50
    # previous/next page links need to pass
    # manually set limit
    if params[:limit].nil?
      @limit = 50
      @page_link = "?"
    else
      @limit = params[:limit].to_i
      @page_link = "?limit=#{@limit}&"
    end
    if params[:page].nil?
      @page=1
    else
      @page = params[:page].to_i   
    end

    # gets last page of table's results
    if params[:model].last
      last_page = params[:model].last.id/@limit+1 
    else
      last_page = 1
    end
    
    # makes sure no next page link is shown for last page
    @is_last = last_page <= @page
    # makes sure valid page is displayed
    if @is_last 
      @page = last_page
    end


    # @id gets the id of the first entry to display on page
    # specific ids are given based on search results
    if params[:id].nil?
      # default is first on given page if none specifed  
      @id = (@page-1)*@limit+1
    else
      # get id of first entry on given page
      @id = params[:id].to_i          
      @prev = @id/@limit+1
    end        

    unless params[:q].nil?
      search_result = params[:model].where('label LIKE ?', "%#{params[:q]}%")[0]
      unless search_result.nil?
        @id = search_result.id
        @prev = @id/@limit+1      
      end
    end

    @is_first = @id == 1

    @prev ||= @id/@limit
    @next = @id/@limit+2
    @orangelight_browsables = params[:model].where(id: @id..(@id+@limit-1))
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

