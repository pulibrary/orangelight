class Orangelight::BrowsablesController < ApplicationController
  before_action :set_orangelight_browsable, only: [:show]

  # GET /orangelight/names
  # GET /orangelight/names.json
  def index
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
    if params[:id].nil?
      @id = (@page-1)*@limit+1
    else
      @id = params[:id].to_i          
    end     

    @is_last = (params[:model].last.id/@limit+1) <= @page
    @prev = @id/@limit
    @next = @id/@limit+2
    @orangelight_browsables = params[:model].where(id: @id..(@id+@limit-1))
    @model = @orangelight_browsables[0].class.name.demodulize.tableize
    @list_name = @orangelight_browsables[0].class.name.demodulize.titleize

  end
 
  # GET /orangelight/names/1
  # GET /orangelight/names/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orangelight_browsable
      @orangelight_browsable = params[:model].find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orangelight_browsable_params
      params.require(:orangelight_browsable).permit(:model, :id)
    end
end

