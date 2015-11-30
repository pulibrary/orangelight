require 'library_stdnums'

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  require './lib/orangelight/string_functions'

  def getdir(str, opts={})
    StringFunctions.getdir(str,opts)
  end

  def json_field? field
    field[:hash]
  end

  # This is needed because white space tokenizes regardless of filters
  def left_anchor_strip solr_parameters, user_parameters
    if solr_parameters[:q]
      if solr_parameters[:q].include?("{!qf=$left_anchor_qf pf=$left_anchor_pf}")
        newq = solr_parameters[:q].gsub("{!qf=$left_anchor_qf pf=$left_anchor_pf}", "")
        solr_parameters[:q] = "{!qf=$left_anchor_qf pf=$left_anchor_pf}" + newq.gsub(" ", "")
      end
    end
  end

  def only_home_facets solr_parameters, user_paramters
    solr_parameters['facet.field'], solr_parameters['facet.pivot'] = home_facets, [] unless has_search_parameters?
  end

  # Returns suitable argument to options_for_select method, to create
  # an html select based on #search_field_list with labels for search
  # bar only. Skips search_fields marked :include_in_simple_select => false
  def search_bar_select
    blacklight_config.search_fields.collect do |key, field_def|
      [field_def.dropdown_label || field_def.label,  field_def.key] if should_render_field?(field_def)
    end.compact
  end


  def redirect_browse solr_parameters, user_parameters
    if user_parameters[:search_field] && user_parameters[:controller] != "advanced"
      if user_parameters[:search_field] == "browse_subject" && !params[:id]
        redirect_to "/browse/subjects?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == "browse_cn" && !params[:id]
        redirect_to "/browse/call_numbers?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == "browse_name" && !params[:id]
        redirect_to "/browse/names?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      else
      end

    end
  end

  def tile_sort_starts_with solr_parameters, user_parameters
    if user_parameters[:search_field] == "left_anchor"
      unless params[:sort]
        solr_parameters[:sort] = 'title_sort asc, pub_date_start_sort desc'
        params[:sort] = 'title_sort asc, pub_date_start_sort desc'
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
  def cjk_mm solr_parameters, user_parameters
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
    if str && str.kind_of?(String)
      str.scan(/\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/).size
    else
      0
    end
  end

  def cjk_mm_val
    "3<86%"
  end

  def browse_related_name_hash name
    link_to(name, "/?f[author_s][]=#{name}", class: "search-related-name", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{name}", title: "Search: #{name}") + '  ' + link_to('[Browse]', "/browse/names?q=#{name}", class: "browse-related-name", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{name}", title: "Browse: #{name}")
  end

 # override method to never render saved searches in user_util_links
  def render_saved_searches?
    false
  end

  # google book covers
  def doc_has_thumbnail? isbn
    return false unless isbn
    google = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}").body
    thumbnail_link = JSON.parse(google)
    return false if thumbnail_link['items'].nil?
    return false if thumbnail_link['items'][0]['volumeInfo'].nil?
    !thumbnail_link['items'][0]['volumeInfo']['imageLinks'].nil?
  end

  def get_thumbnail isbn
   google = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}").body
   thumbnail_link = JSON.parse(google)
   thumbnail_link.to_s
   thumbnail_link['items'][0]['volumeInfo']['imageLinks']['smallThumbnail']
  end

  ##
  # Render the heading partial for a document
  #
  # @param [SolrDocument]
  # @return [String]
  def render_document_heading_partial(document = @document)
    render :partial => 'show_header_default'
  end

  def render_icon var
    "<span class='icon icon-#{var.parameterize}'></span>".html_safe
  end

  def other_versions id_nums, bib_id
    fq = ''
    id_nums.each {|n| fq += "other_version_s:#{n} OR "}
    fq.chomp!(' OR ')
    resp = get_fq_solr_response(fq)
    req = JSON.parse(resp.body)
    other_versions = []
    req['response']['docs'].each do |record|
      unless record['id'] == bib_id
        title = record['title_display'].nil? ? "Other version: record['id']" : record['title_display'].first
        other_versions << link_to("#{title}", "/catalog/#{record['id']}", class: 'other_version')
      end
    end
    other_versions.empty? ? [] : [other_versions]
  end

  def oclc_resolve oclc
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

  def isbn_resolve isbn
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

  def issn_resolve issn
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

  def lccn_resolve lccn
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
      "<br/>".html_safe
    end
  end

  private

    def get_fq_solr_response fq
      solr_url = Blacklight.connection_config[:url]
      conn = Faraday.new(:url => solr_url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      facet_request = "/solr/blacklight-core/select?fq=#{fq}&fl=id,title_display,author_display&wt=json"
      conn.get facet_request
    end

end