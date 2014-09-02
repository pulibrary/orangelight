class AdvancedController < BlacklightAdvancedSearch::AdvancedController

  copy_blacklight_config_from(CatalogController)
  layout 'advanced'

end