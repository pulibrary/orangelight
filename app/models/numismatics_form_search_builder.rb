# frozen_string_literal: true
class NumismaticsFormSearchBuilder < SearchBuilder
  self.default_processor_chain += %i[do_not_limit_configured_facets]

  def do_not_limit_configured_facets(solr_params)
    # -1 means do not limit
    limit_configuration = blacklight_config.numismatics_search[:facet_fields].to_h { |field| ["f.#{field}.facet.limit", '-1'] }
    solr_params.merge! limit_configuration
  end
end
