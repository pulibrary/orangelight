# frozen_string_literal: true
# This class is responsible for building a solr query
# that renders an advanced search form
class AdvancedFormSearchBuilder < SearchBuilder
  self.default_processor_chain += %i[use_advanced_configuration only_request_advanced_facets no_documents do_not_limit_configured_facets]

  def use_advanced_configuration(solr_params)
    solr_params.update(solr_params) do |key, value|
      key_as_string = key.to_s
      next value unless blacklight_config.dig('advanced_search', 'form_solr_parameters', key_as_string)

      blacklight_config.advanced_search.form_solr_parameters[key_as_string]
    end
  end

  # :reek:FeatureEnvy
  def only_request_advanced_facets(solr_params)
    solr_params['facet.field'] = facet_fields
    %w[facet.pivot facet.query stats stats.field].each { |unneeded_field| solr_params.delete unneeded_field }
  end

  # :reek:UtilityFunction
  def no_documents(solr_params)
    solr_params['rows'] = 0
  end

  def do_not_limit_configured_facets(solr_params)
    # -1 means do not limit
    limit_configuration = facet_fields.to_h { |field| ["f.#{field}.facet.limit", '-1'] }
    solr_params.merge! limit_configuration
  end

  private

    def facet_fields
      blacklight_config.advanced_search[:form_solr_parameters]['facet.field']
    end
end
