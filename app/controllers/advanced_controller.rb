class AdvancedController < BlacklightAdvancedSearch::AdvancedController

  copy_blacklight_config_from(CatalogController)


  def guided
    unless request.method==:post
      @response = get_advanced_search_facets
    end
  end

end