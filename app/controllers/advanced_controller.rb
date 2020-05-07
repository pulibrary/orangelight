# frozen_string_literal: true

class AdvancedController < BlacklightAdvancedSearch::AdvancedController
  copy_blacklight_config_from(CatalogController)

  def index
    redirect_to '/', params if params[:id]

    super
  end

  def numismatics
    @response = get_advanced_search_facets unless request.method == :post
    render :numismatics
  end
end
