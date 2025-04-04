# frozen_string_literal: false

require 'library_stdnums'

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  require './lib/orangelight/string_functions'

  def json_field?(field)
    field[:hash]
  end

  def linked_record_field?(field)
    field[:link_field]
  end

  # Escape all whitespace characters within Solr queries specifying left anchor query facets
  # Ends all left-anchor searches with wildcards for matches that begin with search string
  # @param solr_parameters [Blacklight::Solr::Request] the parameters for the Solr query
  def prepare_left_anchor_search(solr_parameters)
    return unless left_anchor_search?(solr_parameters)
    solr_parameters.dig('json', 'query', 'bool').each_value do |value|
      value.select { |boolean_query| boolean_query_searches_left_anchored_field?(boolean_query) }.map! do |clause|
        query = escape_left_anchor_query(clause.dig(:edismax, :query).dup)
        query = add_wildcard(query)
        clause.dig(:edismax)[:query] = query
      end
    end
  end

  def left_anchor_search?(solr_parameters)
    return false unless solr_parameters.dig('json', 'query', 'bool')
    has_left_anchor = solr_parameters.dig('json', 'query', 'bool')
                                     .values
                                     .any? { |value| value.select { |clause| boolean_query_searches_left_anchored_field?(clause) } }
    return false unless has_left_anchor

    true
  end

  # Escape all whitespace characters within Solr queries specifying left anchor query facets
  def escape_left_anchor_query(query)
    query.gsub!(/(\s)/, '\\\\\1')
    query.gsub!(/(["\{\}\[\]\^\~])/, '\\\\\1')
    query.gsub!(/[\(\)]/, '')
    query
  end

  # Ends all left-anchor searches with wildcards for matches that begin with search string
  def add_wildcard(query)
    query.end_with?('*') ? query : query + '*'
  end

  def pul_holdings(solr_parameters)
    return unless blacklight_params[:f_inclusive] && blacklight_params[:f_inclusive][:advanced_location_s]&.include?('pul')
    solr_parameters[:fq].map! { |fq| fq.gsub '"pul"', '*' }
                        .reject! { |fq| fq == '{!term f=advanced_location_s}pul' }
    solr_parameters[:fq] << '-id:SCSB*'
  end

  def series_title_results(solr_parameters)
    return unless includes_series_search?
    solr_parameters[:fl] = 'id,score,author_display,marc_relator_display,format,pub_created_display,'\
                           'title_display,title_vern_display,isbn_s,oclc_s,lccn_s,holdings_1display,'\
                           'electronic_access_1display,electronic_portfolio_s,cataloged_tdt,series_display'
  end

  def includes_series_search?
    blacklight_params['clause'].map { |clause| clause[1]["field"] }.include?('series_title' || 'in_series') if blacklight_params['clause'].present?
  end

  # only fetch facets when an html page is requested
  def html_facets(solr_parameters)
    return if blacklight_params[:format].nil? || blacklight_params[:format] == 'html' ||
              blacklight_params[:format] == 'json'
    solr_parameters[:facet] = false
  end

  # Adapted from http://discovery-grindstone.blogspot.com/2014/01/cjk-with-solr-for-libraries-part-12.html
  def cjk_mm(solr_parameters)
    if blacklight_params && blacklight_params[:q].present?
      q_str = blacklight_params[:q]
      number_of_unigrams = cjk_unigrams_size(q_str)
      if number_of_unigrams > 2
        num_non_cjk_tokens = q_str.scan(/[[:alnum]]+/).size
        if num_non_cjk_tokens.positive?
          lower_limit = cjk_mm_val[0].to_i
          mm = (lower_limit + num_non_cjk_tokens).to_s + cjk_mm_val[1, cjk_mm_val.size]
          solr_parameters['mm'] = mm
        else
          solr_parameters['mm'] = cjk_mm_val
        end
      end
    end
  end

  def cjk_unigrams_size(str)
    if str&.is_a?(String)
      str.scan(/\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/).size
    else
      0
    end
  end

  def cjk_mm_val
    '3<86%'
  end

  def browse_related_name_hash(name)
    link_to(name, "/?f[author_s][]=#{CGI.escape name}", class: 'search-related-name', 'data-original-title' => "Search: #{name}") + '  ' +
      link_to('[Browse]', "/browse/names?q=#{CGI.escape name}", class: 'browse-related-name', 'data-original-title' => "Search: #{name}")
  end

  # render_document_heading from Blacklight v7.23.0.1
  # https://github.com/projectblacklight/blacklight/blob/242880eacb1c73a2a6a3d7cdf4e24cec151179f8/app/helpers/blacklight/blacklight_helper_behavior.rb#L245
  def render_document_heading(*args)
    options = args.extract_options!
    document = args.first
    tag = options.fetch(:tag, :h4)
    document ||= @document
    content_tag(tag, document_presenter(document).heading, itemprop: "name", lang: language_iana)
  end

  ##
  # Render the heading partial for a document
  #
  # @param [SolrDocument]
  # @return [String]
  def render_document_heading_partial(_document = @document)
    render partial: 'show_header_default'
  end

  # Generates markup for a <span> elements containing icons given a string value
  # @param value [String] value used for the CSS class
  # @return [String] markup for the <span> element
  def render_icon(var)
    "<span class='icon icon-#{var.parameterize}' aria-hidden='true'></span>".html_safe
  end

  # Generate the link to "start over" searches
  # @param path [String] the URL path for the link
  # @return [String] the markup for the link
  def render_start_over_link(path)
    child = "<span class=\"icon-refresh\" aria-hidden=\"true\"></span> <span>#{t('blacklight.search.start_over')}</span>"
    link_to(child.html_safe, path, class: 'catalog_startOverLink btn btn-primary', id: 'startOverLink')
  end

  # Generate the link to citations for Documents
  # @param path [String] the URL path for the link
  # @return [String] the markup for the link
  def render_cite_link(path)
    child = "<span class=\"icon-cite\" aria-hidden=\"true\"></span> #{t('blacklight.search.cite')}"
    link_to(child.html_safe, path, id: 'citeLink', data: { blacklight_modal: 'trigger' }, class: 'btn btn-default')
  end

  # Retrieve an instance of the FacetedQueryService
  # @return [FacetedQueryService] an instance of the service object
  def faceted_query_service
    @faceted_query_service ||= FacetedQueryService.new(Blacklight)
  end

  def oclc_resolve(oclc)
    oclc_norm = StringFunctions.oclc_normalize(oclc)
    unless oclc_norm.nil?
      fq = "oclc_s:#{oclc_norm}"
      resp = faceted_query_service.get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if oclc_norm.to_i.zero? || req['response']['docs'].empty?
      "/catalog?q=#{oclc}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  def isbn_resolve(isbn)
    isbn_norm = StdNum::ISBN.normalize(isbn)
    unless isbn_norm.nil?
      fq = "isbn_s:#{isbn_norm}"
      resp = faceted_query_service.get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if isbn_norm.nil? || req['response']['docs'].empty?
      "/catalog?q=#{isbn}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  def issn_resolve(issn)
    issn_norm = StdNum::ISSN.normalize(issn)
    unless issn_norm.nil?
      fq = "issn_s:#{issn_norm}"
      resp = faceted_query_service.get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if issn_norm.nil? || req['response']['docs'].empty?
      "/catalog?q=#{issn}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  def lccn_resolve(lccn)
    lccn_norm = StdNum::LCCN.normalize(lccn)
    unless lccn_norm.nil?
      fq = "lccn_s:#{lccn_norm}"
      resp = faceted_query_service.get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if lccn_norm.nil? || req['response']['docs'].empty?
      "/catalog?q=#{lccn}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  # Links to correct advanced search page based on advanced_type parameter value
  def edit_search_link
    url = advanced_path(params.permit!.except(:controller, :action).to_h)
    if params[:advanced_type] == 'numismatics'
      url.gsub('/advanced', '/numismatics')
    else
      url
    end
  end

  def link_back_to_catalog_safe(opts = { label: nil })
    link_back_to_catalog(opts)
  rescue ActionController::UrlGenerationError
    # This exception is triggered if the user's session has information that results in an
    # invalid back to catalog link. In that case, rather than blowing up on the user, we
    # render a valid link. This link does not preserve the user's previous setings and that is
    # OK because very likely their session is corrupted.
    link_to "Back to search", root_url
  end

    private

      def boolean_query_searches_left_anchored_field?(boolean_query)
        ["${left_anchor_qf}", "${in_series_qf}"].include? boolean_query.dig(:edismax, :qf)
      end
end
