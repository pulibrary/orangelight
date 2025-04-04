# frozen_string_literal: true
require './lib/orangelight/solr/guided_search_builder_behavior'

# This class is responsible for building a solr query
# that renders a guided search form
class GuidedFormSearchBuilder < Blacklight::SearchBuilder
  include Orangelight::Solr::GuidedSearchBuilderBehavior
  self.default_processor_chain = []
end
