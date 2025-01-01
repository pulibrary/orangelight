# frozen_string_literal: true
# This class is responsible for building a solr query
# that renders an advanced search form
class AdvancedFormSearchBuilder < SearchBuilder
  self.default_processor_chain += %i[do_not_limit_languages only_request_advanced_facets]

  def do_not_limit_languages(solr_params)
    solr_params.update(solr_params) do |key, value|
      if key.to_s == 'f.language_facet.facet.limit'
        "-1"
      else
        value
      end
    end
  end

  # :reek:FeatureEnvy
  def only_request_advanced_facets(solr_params)
    solr_params['facet.field'] = blacklight_config.facet_fields.values.select(&:include_in_advanced_search).map(&:key)
    %w[facet.pivot facet.query stats stats.field].each { |unneeded_field| solr_params.delete unneeded_field }
  end
end
