# frozen_string_literal: true

class EventProcessor
  class DeleteProcessor < Processor
    # rubocop:disable Naming/PredicateMethod
    def process
      index.delete_by_query "id:#{RSolr.solr_escape(id)}"
      index.commit unless bulk?
      true
    end
    # rubocop:enable Naming/PredicateMethod
  end
end
