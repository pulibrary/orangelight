
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

  def isbn_norm isbn
   isbn[0][/[0-9]{10,13}/] if isbn
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

  def multiple_holdings? document, field_name
    field_name == 'call_number_display' and document[field_name].size > 2
  end

  # def altscript! values
  #   values.each_with_index do |contents, i|
  #     if getdir(contents) == "rtl"
  #       values[i] = ("<div dir=\"rtl\">" + contents + "</div>").html_safe
  #     end
  #   end
  # end

  # def render_value value=nil, field_config=nil
  #   safe_value = value.respond_to?(:force_encoding) ? value.force_encoding("UTF-8") : value

  #   if field_config and field_config.itemprop
  #     safe_value = content_tag :span, safe_value, :itemprop => field_config.itemprop
  #   end
  #   safe_value
  # end

  # no longer needs to be overriden
  # def presenter_class
  #   PrincetonPresenter
  # end

  # def render_document_show_field_value *args
  #   options = args.extract_options!
  #   document = args.shift || options[:document]

  #   field = args.shift || options[:field]
  #   presenter(document).render_document_show_field_value field, options
  # end

  class PrincetonPresenter < Blacklight::DocumentPresenter
    def field_value_separator
      "<br/>".html_safe
    end
  end
end