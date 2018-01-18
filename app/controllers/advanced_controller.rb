# frozen_string_literal: true

class AdvancedController < BlacklightAdvancedSearch::AdvancedController
  copy_blacklight_config_from(CatalogController)
end
