# frozen_string_literal: false

module ApplicationHelper
  include Requests::Aeon
  require './lib/orangelight/string_functions'

  # Check the Rails Environment. Currently used for Matomo to support production.
  def rails_env?
    Rails.env.production?
  end

  # Generate an Array of <div> elements wrapping links to proxied service endpoints for access
  # Takes first 2 links for pairing with online holdings in search results
  # @param electronic_access [Hash] electronic resource information
  # @return [Array<String>] array containing the links in the <div>'s
  def search_links(electronic_access)
    urls = []
    unless electronic_access.nil?
      links_hash = JSON.parse(electronic_access)
      links_hash.first(2).each do |url, text|
        link = link_to(text.first, EzProxyService.ez_proxy_url(url), target: '_blank', rel: 'noopener')
        link = "#{text[1]}: ".html_safe + link if text[1]
        urls << content_tag(:div, link, class: 'library-location')
      end
    end
    urls
  end

  # Returns electronic portfolio links for Alma records.
  # @param document [SolrDocument]
  # @return [Array<String>] array containing the links
  def electronic_portfolio_links(document)
    return [] if document.try(:electronic_portfolios).blank?
    document.electronic_portfolios.map do |portfolio|
      content_tag(:div, class: 'library-location') do
        link_to(portfolio["title"], portfolio["url"], target: '_blank', rel: 'noopener')
      end
    end
  end

  # Retrieve a URL for a stack map location URL given a record, a call number, and the library in which it is held
  # @param location [Hash] location information for the item holding
  # @param document [SolrDocument] the Solr Document for the record
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the item is held
  # @return [StackmapService::Url] the stack map location
  def locate_url(location, document, call_number, library = nil)
    locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
    ::StackmapService::Url.new(document:, loc: location, cn: call_number).url unless locator.exclude?(call_number:, library:)
  end

  # Generate the link markup (styled with a glyphicon image) for a given item holding within a library
  # @param location [Hash] location information for the item holding
  # @param document [SolrDocument] the Solr Document for the record
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the item is held
  # @return [String] the markup
  def locate_link_with_glyph(location, document, call_number, library, location_name)
    link = locate_url(location, document, call_number, library)
    if link.nil? || (find_it_location?(location) == false)
      ''
    elsif Flipflop.firestone_locator?
      stackmap_url_markup(location, library, location_name, document['id'], call_number)
    else
      stackmap_span_markup(location, library, location_name)
    end
  end

  def stackmap_url_markup(location, library, location_name, doc_id, call_number)
    stackmap_url = "/catalog/#{doc_id}/stackmap?loc=#{location}"
    stackmap_url << "&cn=#{call_number}" if call_number

    ' ' + link_to('<span class="fa fa-map-marker" aria-hidden="true"></span>'.html_safe, stackmap_url, title: t('blacklight.holdings.stackmap'), class: 'find-it', data: { 'map-location': location.to_s, 'blacklight-modal': 'trigger', 'location-library': library, 'location-name': location_name }, 'aria-label' => 'Where to find it')
  end

  def stackmap_span_markup(location, library, location_name)
    ' ' + content_tag(
      :span, '',
      data: {
        'map-location': location.to_s,
        'location-library': library,
        'location-name': location_name
      }
    )
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

  # Generate the markup block for individual search result items containing holding information
  # @param document [SolrDocument] the Solr Document retrieved in the search result set
  # @return [String] the markup
  def holding_block_search(document)
    block = ''
    portfolio_links = electronic_portfolio_links(document)

    links = search_links(document['electronic_access_1display']) + portfolio_links
    holdings_hash = document.holdings_all_display
    scsb_multiple = false
    holdings_hash.first(2).each do |id, holding|
      location = holding_location(holding)
      check_availability = render_availability?
      info = ''
      if holding['library'] == 'Online'
        check_availability = false
        if links.empty?
          check_availability = render_availability?
          info << content_tag(:span, 'Link Missing',
                              class: 'availability-icon badge badge-secondary', title: 'Availability: Online',
                              'data-toggle' => 'tooltip')
          info << content_tag(:div, 'Online access is not currently available.', class: 'library-location')
        else
          info << content_tag(:span, 'Online', class: 'availability-icon badge badge-primary', title: 'Electronic access', 'data-toggle' => 'tooltip')
          info << links.shift.html_safe
        end
      else
        if holding['dspace'] || holding['location_code'] == 'rare$num'
          check_availability = false
          info << content_tag(:span, 'On-site access', class: 'availability-icon badge badge-success', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe if aeon_location?(location)
        elsif /^scsb.+/.match? location[:code]
          check_availability = false
          unless holding['items'].nil?
            scsb_multiple = true unless holding['items'].count == 1
            if scsb_supervised_items?(holding)
              info << content_tag(:span, 'On-site access', class: 'availability-icon badge badge-success', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
              info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe
            else
              info << content_tag(:span, '', class: 'availability-icon badge', title: '', 'data-scsb-availability' => 'true', 'data-toggle' => 'tooltip', 'data-scsb-barcode' => holding['items'].first['barcode'].to_s).html_safe
            end
          end
        elsif holding['dspace'].nil?
          info << content_tag(:span, 'Loading...', class: 'availability-icon badge badge-secondary').html_safe
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe if aeon_location?(location)
        else
          check_availability = false
          info << content_tag(:span, 'Unavailable', class: 'availability-icon badge badge-danger', title: 'Availability: Material under embargo', 'data-toggle' => 'tooltip')
        end
        info << content_tag(:div, search_location_display(holding, document), class: 'library-location', data: { location: true, record_id: document['id'], holding_id: id })
      end

      block << content_tag(:li, info.html_safe, class: 'holding-status', data: { availability_record: check_availability, record_id: document['id'], holding_id: id, temp_location_code: holding['temp_location_code'], aeon: aeon_location?(location), bound_with: document.bound_with? }.compact)

      cdl_placeholder = content_tag(:span, '', class: 'badge badge-primary', 'data-availability-cdl' => true)
      block << content_tag(:li, cdl_placeholder.html_safe)
    end

    if scsb_multiple == true
      block << content_tag(:li, link_to('View Record for Full Availability', solr_document_path(document['id']), class: 'availability-icon badge badge-secondary more-info', title: 'Click on the record for full availability info', 'data-toggle' => 'tooltip').html_safe)
    elsif holdings_hash.length > 2
      block << content_tag(:span, "View record for information on additional holdings", "style" => "font-size: small; font-style: italic;")
    elsif !holdings_hash.empty?
      block << content_tag(:li, link_to('', solr_document_path(document['id']),
                                        class: 'availability-icon more-info', title: 'Click on the record for full availability info',
                                        'data-toggle' => 'tooltip').html_safe, class: 'empty', data: { record_id: document['id'] })
    end

    if block.empty? && links.present?
      # All other options came up empty but since we have electronic access let's show the
      # Online badge with the electronic access link (rather than a misleading "No holdings")
      info = ''
      info << content_tag(:span, 'Online', class: 'availability-icon badge badge-primary', title: 'Electronic access', 'data-toggle' => 'tooltip')
      info << links.shift.html_safe
      block << content_tag(:li, info.html_safe)
    end

    if block.empty?
      content_tag(:div, t('blacklight.holdings.search_missing'))
    else
      content_tag(:ul, block.html_safe)
    end
  end

  # Location display in the search results page
  def search_location_display(holding, document)
    location = holding_location_label(holding)
    render_arrow = (location.present? && holding['call_number'].present?)
    arrow = render_arrow ? ' &raquo; ' : ''
    cn_value = holding['call_number_browse'] || holding['call_number']
    locate_link = locate_link_with_glyph(holding['location_code'], document, cn_value, holding['library'], holding['location'])
    location_display = content_tag(:span, location, class: 'results_location') + arrow.html_safe +
                       content_tag(:span, %(#{holding['call_number']}#{locate_link}).html_safe, class: 'call-number')
    location_display.html_safe
  end

  SEPARATOR = '—'.freeze
  QUERYSEP = '—'.freeze
  def subjectify(args)
    all_subjects = []
    sub_array = []
    args[:document][args[:field]].each_with_index do |subject, i|
      spl_sub = subject.split(QUERYSEP)
      sub_array << []
      subjectaccum = ''
      spl_sub.each_with_index do |subsubject, j|
        spl_sub[j] = subjectaccum + subsubject
        subjectaccum = spl_sub[j] + QUERYSEP
        sub_array[i] << spl_sub[j]
      end
      all_subjects[i] = subject.split(QUERYSEP)
    end
    subject_list = args[:document][args[:field]].each_with_index do |_subject, i|
      lnk = ''
      lnk_accum = ''
      full_sub = ''
      all_subjects[i].each_with_index do |subsubject, j|
        lnk = lnk_accum + link_to(subsubject,
                                  "/?f[subject_facet][]=#{CGI.escape sub_array[i][j]}", class: 'search-subject', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{sub_array[i][j]}", title: "Search: #{sub_array[i][j]}")
        lnk_accum = lnk + content_tag(:span, SEPARATOR, class: 'subject-level')
        full_sub = sub_array[i][j]
      end
      lnk += '  '
      lnk += link_to('[Browse]', "/browse/subjects?q=#{CGI.escape full_sub}", class: 'browse-subject', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{full_sub}", title: "Browse: #{full_sub}", dir: full_sub.dir.to_s)
      args[:document][args[:field]][i] = lnk.html_safe
    end
    content_tag :ul do
      subject_list.each { |subject| concat(content_tag(:li, subject, dir: subject.dir)) }
    end
  end

  def title_hierarchy(args)
    titles = JSON.parse(args[:document][args[:field]])
    all_links = []
    dirtags = []

    titles.each do |title|
      title_links = []
      title.each_with_index do |part, index|
        link_accum = StringFunctions.trim_punctuation(title[0..index].join(' '))
        title_links << link_to(part, "/?search_field=left_anchor&q=#{CGI.escape link_accum}", class: 'search-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{link_accum}", title: "Search: #{link_accum}")
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
          name_title_links << link_to(part, "/?f[author_s][]=#{CGI.escape link_accum}", class: 'search-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{link_accum}", title: "Search: #{link_accum}")
        else
          name_title_links << link_to(part, "/?f[name_title_browse_s][]=#{CGI.escape link_accum}", class: 'search-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{link_accum}", title: "Search: #{link_accum}")
        end
      end
      full_name_title = name_t.join(' ')
      dirtags << StringFunctions.trim_punctuation(full_name_title.dir.to_s)
      name_title_links << link_to('[Browse]', "/browse/name_titles?q=#{CGI.escape full_name_title}", class: 'browse-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{full_name_title}", title: "Browse: #{full_name_title}", dir: full_name_title.dir.to_s)
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

  # Returns true for locations where the user can walk and fetch an item.
  # Currently this logic is duplicated in Javascript code in availability.es6
  def find_it_location?(location_code)
    return false if (location_code || "").start_with?("plasma$", "marquand$")
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
end
