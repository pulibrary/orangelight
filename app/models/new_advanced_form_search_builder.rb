# frozen_string_literal: true
# This class is responsible for building a solr query
# that renders an advanced search form
class NewAdvancedFormSearchBuilder < Blacklight::SearchBuilder
  self.default_processor_chain += %i[no_documents]

  # :reek:UtilityFunction
  def no_documents(solr_params)
    solr_params['rows'] = 0
  end
end
