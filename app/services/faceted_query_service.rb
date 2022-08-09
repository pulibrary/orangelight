# frozen_string_literal: true

class FacetedQueryService
  # Constructor
  # @param blacklight_context [Class] Blacklight Class providing the global context
  def initialize(blacklight_context, rows = 10)
    @blacklight_context = blacklight_context
    @rows = rows
  end

  # Retrieve a response from the Solr endpoint for a faceted query
  # @param fq [String] the Solr facet query
  # @return [Faraday::Response] the HTTP response to the query
  def get_fq_solr_response(fq)
    solr_url = @blacklight_context.connection_config[:url]
    conn = Faraday.new(url: solr_url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    facet_request = \
      "#{core_url}select?fq=#{fq}&fl=id,title_display,author_display,\
      isbn_display,issn_display,lccn_display,oclc_s,holdings_1display,electronic_portfolio_s\
      &rows=#{@rows}&wt=json"
    conn.get facet_request
  end

  # Retrieve the URL for the current Blacklight Solr core
  # @return [String] the URL
  def core_url
    @blacklight_context.default_index.connection.uri.to_s.gsub(%r{^.*\/solr}, '/solr')
  end
end
