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

  # This is needed because white space tokenizes regardless of filters
  def left_anchor_strip(solr_parameters, _user_parameters)
    return unless solr_parameters[:q] && solr_parameters[:q].include?('{!qf=$left_anchor_qf pf=$left_anchor_pf}')
    newq = solr_parameters[:q].gsub('{!qf=$left_anchor_qf pf=$left_anchor_pf}', '')
    solr_parameters[:q] = '{!qf=$left_anchor_qf pf=$left_anchor_pf}' + newq.delete(' ')
  end

  def only_home_facets(solr_parameters, _user_parameters)
    return if has_search_parameters?
    solr_parameters['facet.field'] = home_facets
    solr_parameters['facet.pivot'] = []
  end

  def only_advanced_facets(solr_parameters, user_parameters)
    return unless user_parameters[:controller] == 'advanced'
    solr_parameters['facet.field'] = advanced_facets
    solr_parameters['facet.pivot'] = []
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
    field_def.respond_to?(:placeholder_text) ? field_def.placeholder_text : t('blacklight.search.form.q')
  end

  def redirect_browse(_solr_parameters, user_parameters)
    if user_parameters[:search_field] && user_parameters[:controller] != 'advanced'
      if user_parameters[:search_field] == 'browse_subject' && !params[:id]
        redirect_to "/browse/subjects?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == 'browse_cn' && !params[:id]
        redirect_to "/browse/call_numbers?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == 'browse_name' && !params[:id]
        redirect_to "/browse/names?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      end

    end
  end

  def search_bar_field
    if params[:model] == Orangelight::CallNumber
      'browse_cn'
    elsif params[:model] == Orangelight::Name
      'browse_name'
    elsif params[:model] == Orangelight::Subject
      'browse_subject'
    else
      params[:search_field]
    end
  end

  # Adapted from http://discovery-grindstone.blogspot.com/2014/01/cjk-with-solr-for-libraries-part-12.html
  def cjk_mm(solr_parameters, user_parameters)
    if user_parameters && user_parameters[:q].present?
      q_str = user_parameters[:q]
      number_of_unigrams = cjk_unigrams_size(q_str)
      if number_of_unigrams > 2
        num_non_cjk_tokens = q_str.scan(/[[:alnum]]+/).size
        if num_non_cjk_tokens > 0
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
    if str && str.is_a?(String)
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

  # override method to never render saved searches in user_util_links
  def render_saved_searches?
    false
  end

  ##
  # Render the heading partial for a document
  #
  # @param [SolrDocument]
  # @return [String]
  def render_document_heading_partial(_document = @document)
    render partial: 'show_header_default'
  end

  def render_icon(var)
    "<span class='icon icon-#{var.parameterize}'></span>".html_safe
  end

  # solr fq field is field parameter provided unless id_nums value starts with BIB
  def linked_records(id_nums, bib_id, field)
    fq = ''
    id_nums.each do |n|
      bib_match = /(?:^BIB)(.*)/.match(n)
      solr_field = bib_match ? 'id' : field
      n = bib_match[1] if bib_match
      fq += "#{solr_field}:#{n} OR "
    end
    fq.chomp!(' OR ')
    resp = get_fq_solr_response(fq)
    req = JSON.parse(resp.body)
    other_versions = []
    req['response']['docs'].each do |record|
      unless record['id'] == bib_id
        title = record['title_display']
        other_versions << link_to(title, catalog_url(record['id']))
      end
    end
    other_versions.empty? ? [] : [other_versions]
  end

  def oclc_resolve(oclc)
    oclc_norm = StringFunctions.oclc_normalize(oclc)
    unless oclc_norm.nil?
      fq = "oclc_s:#{oclc_norm}"
      resp = get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if oclc_norm == 0 || req['response']['docs'].empty?
      "/catalog?q=#{oclc}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  def isbn_resolve(isbn)
    isbn_norm = StdNum::ISBN.normalize(isbn)
    unless isbn_norm.nil?
      fq = "isbn_s:#{isbn_norm}"
      resp = get_fq_solr_response(fq)
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
      resp = get_fq_solr_response(fq)
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
      resp = get_fq_solr_response(fq)
      req = JSON.parse(resp.body)
    end
    if lccn_norm.nil? || req['response']['docs'].empty?
      "/catalog?q=#{lccn}"
    else
      "/catalog/#{req['response']['docs'].first['id']}"
    end
  end

  class PrincetonPresenter < Blacklight::DocumentPresenter
    def field_value_separator
      '<br/>'.html_safe
    end
  end

  private

    def get_fq_solr_response(fq)
      solr_url = Blacklight.connection_config[:url]
      conn = Faraday.new(url: solr_url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      facet_request = "/solr/blacklight-core/select?fq=#{fq}&fl=id,title_display,author_display&wt=json"
      conn.get facet_request
    end
end
