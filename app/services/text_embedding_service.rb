# frozen_string_literal: true
# This service will connect to a VM that hosts the sentence transformers and the embedding process

class TextEmbeddingService
  def initialize(query)
    @query = query.to_s
  end

  def query_to_vector
    # we will host sentence transormers and
    # the embedding process on a separate VM EmbeddingService
    # we have built a FastAPI in python to do this workq
    # this method will return the encoded query we pass in the search box
    # [90,78,68,92,108,82,-9,74,103,-55,-66,-121,108,44,70,-80,-73,-26,-69,-8,-22,-106,-8,-42,-22,-89,127,-1,85,66,108,118,2,71,59,78,26,-67,10,66,-91,-76,-128,-127,4,31,-9,-96,98,29,-25,74,39,-70,100,-90,106,-51,57,-32,-70,-35,0,63,52,20,-35,126,99,-60,-107,92,-103,93,-60,120,-117,18,-79,-78,-64,-128,-123,-67,-60,-56,27,100,-117,86,-9,37,-126,33,43,70]
    response = connection.post('/embedding') do |req|
      req.body = { text: @query }
    end
    raise "Embedding API error: #{response.status} - #{response.body}" unless response.success?

    # for testing purposes we're doing the round here and in bibdata.
    # if the results are satisfiying we move the precision limit in the embedding python service
    vector = response.body['embedding']

    raise 'Embedding API response missing embedding array' unless vector.is_a?(Array)

    vector
  end

  private

    def connection
      @connection ||= Faraday.new(url: ENV.fetch('EMBEDDING_BASE', 'http://localhost:8000')) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end
end
