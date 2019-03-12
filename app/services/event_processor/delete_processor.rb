# frozen_string_literal: true

class EventProcessor
  class DeleteProcessor < Processor
    def process
      index.delete_by_query "id:#{RSolr.solr_escape(id)}"
      index.commit unless bulk?
      true
    end
  end
end
