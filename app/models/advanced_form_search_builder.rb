# frozen_string_literal: true
# This class is responsible for building a solr query
# that renders an advanced search form
class AdvancedFormSearchBuilder < SearchBuilder
  self.default_processor_chain += %i[do_not_limit_languages]

  def do_not_limit_languages(solr_params)
    solr_params.update(solr_params) do |key, value|
      if key.to_s == 'f.language_facet.facet.limit'
        "-1"
      else
        value
      end
    end
  end
end
