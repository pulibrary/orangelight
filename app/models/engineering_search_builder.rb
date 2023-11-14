# frozen_string_literal: true

# This is a demonstration search builder, not intended for prodcution use.
class EngineeringSearchBuilder < SearchBuilder
  self.default_processor_chain += [:switch_request_handler]

  def switch_request_handler(solr_parameters)
    solr_parameters[:qt] = "engineering_search"
  end
end
