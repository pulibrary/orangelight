# frozen_string_literal: false

module ApplicationHelper
  require './lib/orangelight/string_functions'

  # Check the Rails Environment. Currently used for Matomo to support production.
  def rails_env?
    Rails.env.production?
  end

  def show_regular_search?
    !((%w[generate numismatics advanced_search].include? params[:action]) || (%w[advanced].include? params[:controller]))
  end

  # Generate the markup for the block containing links for requests to item holdings
  # holding record fields: 'location', 'library', 'location_code', 'call_number', 'call_number_browse',
  # 'shelving_title', 'location_note', 'electronic_access_1display', 'location_has', 'location_has_current',
  # 'indexes', 'supplements'
  # process online and physical holding information at the same time
  # @param [SolrDocument] document - record display fields
  # @return [String] online - online holding info html
  # @return [String] physical - physical holding info html
  def holding_request_block(document)
    adapter = HoldingRequestsAdapter.new(document, Bibdata)
    markup_builder = HoldingRequestsBuilder.new(adapter:,
                                                online_markup_builder: OnlineHoldingsMarkupBuilder,
                                                physical_markup_builder: PhysicalHoldingsMarkupBuilder)
    online_markup, physical_markup = markup_builder.build
    [online_markup, physical_markup]
  end

  # Determine whether or not a ReCAP holding has items restricted to supervised use
  # @param holding [Hash] holding values
  # @return [TrueClass, FalseClass]
  def scsb_supervised_items?(holding)
    if holding.key? 'items'
      restricted_items = holding['items'].select { |item| item['use_statement'] == 'Supervised Use' }
      restricted_items.count == holding['items'].count
    else
      false
    end
  end

  # Blacklight index field helper for the facet "series_display"
  # @param args [Hash]
  def series_results(args)
    series_display =
      if params[:f1] == 'in_series'
        same_series_result(params[:q1], args[:document][args[:field]])
      else
        args[:document][args[:field]]
      end
    series_display.join(', ')
  end

  # Retrieve the same series for that one being displayed
  # @param series [String] series name
  # @param series_display [Array<String>] series being displayed
  # @param [Array<String>] similarly named series
  def same_series_result(series, series_display)
    series_display.select { |t| t.start_with?(series) }
  end

  # Determines whether or not this is an aeon location (for an item holding)
  # @param location [Hash] location values
  # @return [TrueClass, FalseClass]
  def aeon_location?(location)
    location.nil? ? false : location[:aeon_location]
  end

  # Retrieve the location information for a given item holding
  # @param [Hash] holding values
  def holding_location(holding)
    location_code = holding.fetch('location_code', '').to_sym
    resolved_location = Bibdata.holding_locations[location_code]
    resolved_location ? resolved_location : {}
  end

  # Location display in the search results page
  def search_location_display(holding)
    location = holding_location_label(holding)
    render_arrow = (location.present? && holding['call_number'].present?)
    arrow = render_arrow ? ' &raquo; ' : ''
    location_display = content_tag(:span, location, class: 'results_location') + arrow.html_safe +
                       content_tag(:span, holding['call_number'], class: 'call-number')
    location_display.html_safe
  end

  def subjectify(args)
    subjects = args[:document][args[:field]]
    all_subjects = subjects.map { |subject| subject.split(QUERYSEP) }
    sub_array = subjects.map { |subject| accumulate_subsubjects(subject.split(QUERYSEP)) }
    subject_list = build_subject_list(args, all_subjects, sub_array)
    build_subject_ul(subject_list)
  end

  def title_hierarchy(args)
    titles = JSON.parse(args[:document][args[:field]])
    all_links = []
    dirtags = []

    titles.each do |title|
      title_links = []
      title.each_with_index do |part, index|
        link_accum = StringFunctions.trim_punctuation(title[0..index].join(' '))
        title_links << link_to(part, "/?search_field=left_anchor&q=#{CGI.escape link_accum}", class: 'search-title', 'data-original-title' => "Search: #{link_accum}", title: "Search: #{link_accum}")
      end
      full_title = title.join(' ')
      dirtags << StringFunctions.trim_punctuation(full_title.dir.to_s)
      all_links << title_links.join('<span> </span>').html_safe
    end

    if all_links.length == 1
      all_links = content_tag(:div, all_links[0], dir: dirtags[0])
    else
      all_links = all_links.map.with_index { |l, i| content_tag(:li, l, dir: dirtags[i]) }
      all_links = content_tag(:ul, all_links.join.html_safe)
    end
    all_links
  end

  def action_notes_display(args)
    action_notes = JSON.parse(args[:document][args[:field]])
    lines = action_notes.map do |note|
      if note["uri"].present?
        link_to(note["description"], note["uri"])
      else
        note["description"]
      end
    end

    if lines.length == 1
      lines = content_tag(:div, lines[0])
    else
      lines = lines.map.with_index { |l| content_tag(:li, l) }
      lines = content_tag(:ul, lines.join.html_safe)
    end
    lines
  end

  def name_title_hierarchy(args)
    name_titles = JSON.parse(args[:document][args[:field]])
    all_links = []
    dirtags = []
    name_titles.each do |name_t|
      name_title_links = []
      name_t.each_with_index do |part, i|
        link_accum = StringFunctions.trim_punctuation(name_t[0..i].join(' '))
        if i.zero?
          next if args[:field] == 'name_uniform_title_1display'
          name_title_links << link_to(part, "/?f[author_s][]=#{CGI.escape link_accum}", class: 'search-name-title', 'data-original-title' => "Search: #{link_accum}")
        else
          name_title_links << link_to(part, "/?f[name_title_browse_s][]=#{CGI.escape link_accum}", class: 'search-name-title', 'data-original-title' => "Search: #{link_accum}")
        end
      end
      full_name_title = name_t.join(' ')
      dirtags << StringFunctions.trim_punctuation(full_name_title.dir.to_s)
      name_title_links << link_to('[Browse]', "/browse/name_titles?q=#{CGI.escape full_name_title}", class: 'browse-name-title', 'data-original-title' => "Browse: #{full_name_title}", dir: full_name_title.dir.to_s)
      all_links << name_title_links.join('<span> </span>').html_safe
    end

    if all_links.length == 1
      all_links = content_tag(:div, all_links[0], dir: dirtags[0])
    else
      all_links = all_links.map.with_index { |l, i| content_tag(:li, l, dir: dirtags[i]) }
      all_links = content_tag(:ul, all_links.join.html_safe)
    end
    all_links
  end

  def format_icon(args)
    icon = render_icon(args[:document][args[:field]][0]).to_s
    formats = format_render(args)
    content_tag :ul do
      content_tag :li, " #{icon} #{formats} ".html_safe, class: 'blacklight-format', dir: 'ltr'
    end
  end

  def format_render(args)
    args[:document][args[:field]].join(', ')
  end

  def location_has(args)
    location_notes = JSON.parse(args[:document][:holdings_1display]).collect { |_k, v| v['location_has'] }.flatten
    if location_notes.length > 1
      content_tag(:ul) do
        location_notes.map { |note| content_tag(:li, note) }.join.html_safe
      end
    else
      location_notes
    end
  end

  def bibdata_location_code_to_sym(value)
    Bibdata.holding_locations[value.to_sym]
  end

  def render_location_code(value)
    values = normalize_location_code(value).map do |loc|
      location = Bibdata.holding_locations[loc.to_sym]
      location.nil? ? loc : "#{loc}: #{location_full_display(location)}"
    end
    values.count == 1 ? values.first : values
  end

  # Depending on the url, we sometimes get strings, arrays, or hashes
  # Returns Array of locations
  def normalize_location_code(value)
    case value
    when String
      Array(value)
    when Array
      value
    when Hash, ActiveSupport::HashWithIndifferentAccess
      value.values
    else
      value
    end
  end

  def holding_location_label(holding)
    loc_code = holding['location_code']
    location = bibdata_location_code_to_sym(loc_code) unless loc_code.nil?
    # If the Bibdata location is nil, use the location value from the solr document.
    alma_location_display(holding, location) unless location.blank? && holding.blank?
  end

  # Alma location display on search results
  def alma_location_display(holding, location)
    if location.nil?
      [holding['library'], holding['location']].select(&:present?).join(' - ')
    else
      [location['library']['label'], location['label']].select(&:present?).join(' - ')
    end
  end

  # location = Bibdata.holding_locations[value.to_sym]
  def location_full_display(loc)
    loc['label'] == '' ? loc['library']['label'] : loc['library']['label'] + ' - ' + loc['label']
  end

  def html_safe(args)
    args[:document][args[:field]].each_with_index { |v, i| args[:document][args[:field]][i] = v.html_safe }
  end

  def current_year
    DateTime.now.year
  end

  # Construct an adapter for Solr Documents and the bib. data service
  # @return [HoldingRequestsAdapter]
  def holding_requests_adapter
    HoldingRequestsAdapter.new(@document, Bibdata)
  end

  # Returns true for locations with remote storage.
  # Remote storage locations have a value of 'recap_rmt' in Alma.
  def remote_storage?(location_code)
    Bibdata.holding_locations[location_code]["remote_storage"] == 'recap_rmt'
  end

  # Returns true for locations where the user can walk and fetch an item.
  # Currently this logic is duplicated in Javascript code in availability.es6
  def find_it_location?(location_code)
    return false if remote_storage?(location_code)
    return false if (location_code || "").start_with?("plasma$", "marquand$")

    return false if StackmapService::Url.missing_stackmap_reserves.include?(location_code)

    true
  end

  # Testing this feature with Voice Over - reading the Web content
  # If language defaults to english 'en' when no language_iana_primary_s exists then:
  # for cyrilic: for example russian, voice over will read each character as: cyrilic <character1>, cyrilic <character2>
  # for japanese it announces <character> ideograph
  # If there is no lang attribute it announces the same as having lang='en'
  def language_iana
    @document[:language_iana_s].present? ? @document[:language_iana_s].first : 'en'
  end

  def should_show_viewer?
    request.human? && controller.action_name != "librarian_view"
  end

  private

    SEPARATOR = '—'.freeze
    QUERYSEP = '—'.freeze
    private_constant :SEPARATOR, :QUERYSEP

    def fast_subjects_value?(args, i)
      fast_subject_display_field = args[:document]["fast_subject_display"]
      return false if fast_subject_display_field.nil?
      fast_subject_display_field.present? && fast_subject_display_field.include?(args[:document][args[:field]][i])
    end

    def build_subject_ul(subject_list)
      content_tag :ul do
        subject_list.each { |subject| concat(content_tag(:li, subject, dir: subject.dir)) }
      end
    end

    def build_subject_list(args, all_subjects, sub_array)
      args_document_field = args[:document][args[:field]]
      args_document_field.each_with_index do |_subject, index|
        sub_array_index = sub_array[index]
        lnk = build_search_subject_links(all_subjects[index], sub_array_index)
        lnk += build_browse_subject_link(args, index, sub_array_index.last)
        args_document_field[index] = lnk.html_safe
      end
    end

    def build_search_subject_links(subjects, sub_array)
      lnk = ''
      lnk_accum = ''

      subjects.each_with_index do |subsubject, j|
        sub_array_j = sub_array[j]
        lnk = lnk_accum + link_to(subsubject,
                                  "/?f[subject_facet][]=#{CGI.escape StringFunctions.trim_punctuation(sub_array_j)}",
                                  class: 'search-subject',
                                  'data-original-title' => "Search: #{sub_array_j}")
        lnk_accum = lnk + content_tag(:span, SEPARATOR, class: 'subject-level')
      end
      lnk
    end

    def build_browse_subject_link(args, index, full_sub)
      return '  ' if fast_subjects_value?(args, index)

      '  ' + link_to('[Browse]',
                     "/browse/subjects?q=#{CGI.escape full_sub}",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    end

    def accumulate_subsubjects(spl_sub)
      subjectaccum = ''
      spl_sub.map do |subsubject|
        subjectaccum += subsubject
        result = subjectaccum.dup
        subjectaccum += QUERYSEP
        result
      end
    end
end
