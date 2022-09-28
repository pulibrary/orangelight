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

  def wildcard_char_strip(solr_parameters)
    return unless solr_parameters[:q]
    solr_parameters[:q] = solr_parameters[:q].delete('?')
  end

  # Escape all whitespace characters within Solr queries specifying left anchor query facets
  # Ends all left-anchor searches with wildcards for matches that begin with search string
  # @param solr_parameters [Blacklight::Solr::Request] the parameters for the Solr query
  def left_anchor_escape_whitespace(solr_parameters)
    return unless solr_parameters[:qf] == '${left_anchor_qf}' && solr_parameters[:q]
    query = solr_parameters[:q].dup
    # Escape any remaining whitespace and solr operator characters
    query.gsub!(/(\s)/, '\\\\\1')
    query.gsub!(/(["\{\}\[\]\^\~])/, '\\\\\1')
    query.gsub!(/[\(\)]/, '')
    solr_parameters[:q] = query
    solr_parameters[:q] += '*' unless query.end_with?('*')
  end

  def pul_holdings(solr_parameters)
    return unless blacklight_params[:f_inclusive] && blacklight_params[:f_inclusive][:advanced_location_s] &&
                  blacklight_params[:f_inclusive][:advanced_location_s].include?('pul')
    solr_parameters[:fq].map! { |fq| fq.gsub '"pul"', '*' }
                        .reject! { |fq| fq == '{!term f=advanced_location_s}pul' }
    solr_parameters[:fq] << '-id:SCSB*'
  end

  def series_title_results(solr_parameters)
    return unless %w[series_title in_series].include?(blacklight_params[:f1]) ||
                  blacklight_params[:f2] == 'series_title' ||
                  blacklight_params[:f3] == 'series_title'
    solr_parameters[:fl] = 'id,score,author_display,marc_relator_display,format,pub_created_display,'\
                           'title_display,title_vern_display,isbn_s,oclc_s,lccn_s,holdings_1display,'\
                           'electronic_access_1display,cataloged_tdt,series_display'
  end

  # only fetch facets when an html page is requested
  def html_facets(solr_parameters)
    return if blacklight_params[:format].nil? || blacklight_params[:format] == 'html' ||
              blacklight_params[:format] == 'json'
    solr_parameters[:facet] = false
  end

  # Returns suitable argument to options_for_select method, to create
  # an html select based on #search_field_list with labels for search
  # bar only. Skips search_fields marked :include_in_simple_select => false
  def search_bar_select
    blacklight_config.search_fields.collect do |_key, field_def|
      [field_def.dropdown_label || field_def.label, field_def.key, { 'data-placeholder' => placeholder_text(field_def) }] if should_render_field?(field_def)
    end.compact
  end

  def placeholder_text(field_def)
    field_def.respond_to?(:placeholder_text) ? field_def.placeholder_text : t('blacklight.search.form.search.placeholder')
  end

  def search_bar_field
    if params[:model] == Orangelight::CallNumber
      'browse_cn'
    elsif params[:model] == Orangelight::Name
      'browse_name'
    elsif params[:model] == Orangelight::NameTitle
      'name_title'
    elsif params[:model] == Orangelight::Subject
      'browse_subject'
    else
      params[:search_field]
    end
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
    link_to(name, "/?f[author_s][]=#{CGI.escape name}", class: 'search-related-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{name}", title: "Search: #{name}") + '  ' +
      link_to('[Browse]', "/browse/names?q=#{CGI.escape name}", class: 'browse-related-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{name}", title: "Browse: #{name}")
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
    child = "<span class=\"icon-refresh\" aria-hidden=\"true\"></span> <span class=\"d-none d-lg-inline\">#{t('blacklight.search.start_over')}</span>"
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

  # pulls some logic from blacklight's `link_to_document` helper
  # then adds truncation of link text
  def truncated_link(doc, field_or_string, opts = { counter: nil }, length = 200)
    label_value = if field_or_string.class == String
                    field_or_string
                  else
                    index_presenter(doc).label(field_or_string, opts)
                  end
    label = label_value.truncate(length, separator: /\s/).html_safe
    link_to label, url_for_document(doc), document_link_params(doc, opts)
  end

  # Links to correct advanced search page based on advanced_type parameter value
  def edit_search_link
    url = blacklight_advanced_search_engine.advanced_search_path(params.permit!.except(:controller, :action).to_h)
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
end
