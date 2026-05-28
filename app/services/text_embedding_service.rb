# frozen_string_literal: true
# This service will connect to a VM that hosts the sentence transformers and the embedding process

class TextEmbeddingService
  def initialize(query)
    @query = query
  end

  def query_to_vector
    # we will host sentence transormers and
    # the embedding process on a separate VM
    # this method will return the encoded query we pass in the search box
    [0.010338805615901947, 0.02806314453482628, 0.020983939990401268]
  end
end
