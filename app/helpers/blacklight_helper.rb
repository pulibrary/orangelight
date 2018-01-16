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
  # @param solr_parameters [Blacklight::Solr::Request] the parameters for the Solr query
  def left_anchor_escape_whitespace(solr_parameters)
    return unless solr_parameters[:q]&.include?('{!qf=$left_anchor_qf pf=$left_anchor_pf}')
    query = solr_parameters[:q].gsub('{!qf=$left_anchor_qf pf=$left_anchor_pf}', '')
    # Escape any remaining whitespace
    query.gsub!(/(\s)/, '\\\\\1')
    solr_parameters[:q] = '{!qf=$left_anchor_qf pf=$left_anchor_pf}' + query
  end

  def pul_holdings(solr_parameters)
    return unless blacklight_params[:f_inclusive] && blacklight_params[:f_inclusive][:advanced_location_s] &&
                  blacklight_params[:f_inclusive][:advanced_location_s].include?('pul')
    solr_parameters[:fq].map! { |fq| fq.gsub '"pul"', '*' }
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

  def only_home_facets(solr_parameters)
    return if search_parameters?
    solr_parameters['facet.field'] = home_facets
    solr_parameters['facet.pivot'] = []
  end

  def course_reserve_filters(solr_parameters)
    return unless blacklight_params[:f]
    instructor = Array(blacklight_params[:f][:instructor]).first
    course = Array(blacklight_params[:f][:course]).first
    department = Array(blacklight_params[:f][:department]).first
    filter = Array(blacklight_params[:f][:filter]).first
    return if instructor.blank? && course.blank? && department.blank? && filter.blank?
    courses = CourseReserveRepository.all.query(instructor: instructor, course_with_id: course, department_with_identifier: department)
    index_course_reserves(courses)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq].reject! do |x|
      %w[course instructor department filter].include?(x.split('=')[1].split('}')[0])
    end
    solr_parameters[:fq] << "{!join from=bib_ids_s to=id fromIndex=#{ReserveIndexer.core}}#{courses.solr_query}"
  end

  def index_course_reserves(courses)
    ReserveIndexer.connection.delete_by_query(courses.solr_query)
    ReserveIndexer.index!(courses)
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
    child = "<span class=\"icon-refresh\" aria-hidden=\"true\"></span> <span class=\"hidden-xs hidden-sm\">#{t('blacklight.search.start_over')}</span>"
    link_to(child.html_safe, path, class: 'catalog_startOverLink btn btn-primary', id: 'startOverLink')
  end

  # Generate the link to citations for Documents
  # @param path [String] the URL path for the link
  # @return [String] the markup for the link
  def render_cite_link(path)
    child = "<span class=\"icon-cite\" aria-hidden=\"true\"></span> #{t('blacklight.search.cite')}"
    link_to(child.html_safe, path, id: 'citeLink', data: { ajax_modal: 'trigger' }, class: 'btn btn-default')
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
        other_versions << link_to(title, solr_document_url(record['id']))
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

  # pulls some logic from blacklight's `link_to_document` helper
  # then adds truncation of link text
  def truncated_link(doc, field, opts = { counter: nil }, length = 200)
    label = index_presenter(doc).label(field, opts).truncate(length).html_safe
    link_to label, url_for_document(doc), document_link_params(doc, opts)
  end

  private

    ##
    # Check if any search parameters have been set
    # @return [Boolean]
    def search_parameters?
      blacklight_params[:q].present? || blacklight_params[:f].present? || blacklight_params[:search_field].present?
    end

    def get_fq_solr_response(fq)
      solr_url = Blacklight.connection_config[:url]
      conn = Faraday.new(url: solr_url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      facet_request = "#{core_url}select?fq=#{fq}&fl=id,title_display,author_display&wt=json"
      conn.get facet_request
    end

    def core_url
      Blacklight.default_index.connection.uri.to_s.gsub(%r{^.*\/solr}, '/solr')
    end
end
