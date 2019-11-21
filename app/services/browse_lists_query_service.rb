# frozen_string_literal: true

class BrowseListsQueryService
  def initialize(odm_class:)
    @odm_class = odm_class
  end

  def find_range_by_model(model:, start:, last:)
    query = find_range_by_model_query(model, start, last)
    query_response = connection.get('select', params: query)
    query_response_documents(query_response)
  end

  def find_by_model(model:)
    @documents_by_model = {} if @documents_by_model.nil?

    @documents_by_model[model] ||= begin
                                     query = find_by_model_query(model)
                                     query_response = connection.get('select', params: query)
                                     query_response_documents(query_response)
                                   end
  end

  def find_sorted_by_model(model:, sort_by:)
    query = find_sorted_by_model_query(model, sort_by)
    query_response = connection.get('select', params: query)
    query_response_documents(query_response)
  end

  private

    # All of this needs to be restructured into a QueryService Class
    def connection
      Orangelight.browse_lists_index.connection
    end

    def query_response_documents(query_response)
      query_response["response"]["docs"].map { |doc| @odm_class.new(doc) }
    end

    ## The queries
    def solr_default_params
      {
        sort: solr_default_sort,
        fl: solr_default_fields,
        rows: 100_000_0
      }
    end

    def solr_model_query(model)
      "model_s:#{model}"
    end

    def solr_default_fields
      "id,model_s,index_i,normalized_sort,direction_s,count_i,title_s,author_s,date_s,bibid_s,holding_id_s,location_s,scheme_s,normalized_s"
    end

    def solr_default_sort
      "index_i asc,normalized_sort asc" # The last-added Document should be last
    end

    # Generate the query for finding documents by model within an inclusive range of indices
    # @return [Hash]
    def find_range_by_model_query(model, start, last)
      solr_query = solr_model_query(model)
      range_parameters = {
        q: solr_query
      }
      range_parameters[:fq] = "index_i:[#{start} TO #{last}]" unless start.nil? && last.nil?

      solr_default_params.merge(range_parameters)
    end

    def find_by_model_query(model)
      solr_default_params.merge(
        q: solr_model_query(model)
      )
    end

    def find_sorted_by_model_query(model, search_term)
      solr_query = solr_model_query(model)

      solr_default_params.merge(
        q: solr_query,
        fq: "normalized_sort:[* TO \"#{search_term}\"]",
        sort: "normalized_sort asc"
      )
    end
end
