# frozen_string_literal: false

module ApplicationHelper
  include Requests::Aeon
  require './lib/orangelight/string_functions'

  # Check the Rails Environment. Currently used for Matomo to support production.
  def rails_env?
    Rails.env.production?
  end

  # Generate the markup for the <div> containing a link to the umlaut service endpoint for a given record
  # @param document [SolrDocument] the Solr Document for the record
  # @return [String] the markup
  def umlaut_services_fulltext(document)
    services = ''
    unless document.key? 'electronic_access_1display'
      services << content_tag(:div, '', :id => 'full_text', :class => ['availability--online', 'availability_full-text', 'availability--panel_umlaut'], 'data-umlaut-full-text' => true)
    end
    services.html_safe
  end

  # Generate the markup for two <div> elements containing links to umlaut services
  # @return [String] the markup
  def umlaut_services
    services = ''
    services << content_tag(:div, '', :id => 'excerpts', :class => ['availability--excerpts', 'availability_excerpts', 'availability--panel_umlaut'], 'data-umlaut-services' => true)
    services << content_tag(:div, '', :id => 'highlighted_link', :class => ['availability--highlighted', 'availability_highlighted-link', 'availability--panel_umlaut'], 'data-umlaut-services' => true)
    services.html_safe
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
        link = link_to(text.first, "#{ENV['proxy_base']}#{url}", target: '_blank')
        link = "#{text[1]}: ".html_safe + link if text[1]
        urls << content_tag(:div, link, class: 'library-location')
      end
    end
    urls
  end

  # Retrieve a URL for a stack map location URL given a record, a call number, and the library in which it is held
  # @param location [Hash] location information for the item holding
  # @param document [SolrDocument] the Solr Document for the record
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the item is held
  # @return [StackmapService::Url] the stack map location
  def locate_url(location, document, call_number, library = nil)
    locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
    ::StackmapService::Url.new(document: document, loc: location, cn: call_number).url unless locator.exclude?(call_number: call_number, library: library)
  end

  # Generate the link markup (styled with a glyphicon image) for a given item holding within a library
  # @param location [Hash] location information for the item holding
  # @param document [SolrDocument] the Solr Document for the record
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the item is held
  # @return [String] the markup
  def locate_link_with_glyph(location, document, call_number, library)
    link = locate_url(location, document, call_number, library)
    stackmap_url = "/catalog/#{document['id']}/stackmap?loc=#{location}"
    stackmap_url << "&cn=#{call_number}" if call_number
    if link.nil?
      ''
    else
      ' ' + link_to('<span class="fa fa-map-marker" aria-hidden="true"></span>'.html_safe, stackmap_url, title: t('blacklight.holdings.stackmap'), class: 'find-it', 'data-map-location' => location.to_s, 'data-blacklight-modal' => 'trigger', 'aria-label' => 'Where to find it')
    end
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
    markup_builder = HoldingRequestsBuilder.new(adapter: adapter,
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

  # Blacklight show field helper for the facet "series_display"
  # @param args [Hash]
  def series_with_links(args)
    series_titles = args[:document]['more_in_this_series_t'] || []
    args[:document][args[:field]].each_with_index do |title, i|
      newtitle = title
      unless (series_name = series_titles.select { |t| title.start_with?(t) }.first).nil?
        newtitle << %(  #{more_in_this_series_link(series_name)})
        series_titles.delete(series_name)
      end
      args[:document][args[:field]][i] = newtitle.html_safe
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

  # Generate a query link for all items within a given series using a title
  # @param title [String] the title of the series
  # @return [String] the link markup
  def more_in_this_series_link(title)
    no_parens = title.gsub(/[()]/, '')
    link_to('[More in this series]', "/catalog?q1=#{CGI.escape no_parens}&f1=in_series&search_field=advanced",
            class: 'more-in-series', 'data-toggle' => 'tooltip',
            'data-original-title' => "More in series: #{title}", title: "More in series: #{title}",
            dir: title.dir.to_s)
  end

  # For reference notes that end with a url convert the note into link
  # @param args [Hash]
  def references_url(args)
    args[:document][args[:field]].each_with_index do |reference, i|
      if (url = reference[/ (http.*)$/])
        reference = reference.chomp(url)
        args[:document][args[:field]][i] = link_to(reference, url.gsub(/\s/, ''), target: '_blank')
      end
    end
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
    links = search_links(document['electronic_access_1display'])
    holdings_hash = JSON.parse(document['holdings_1display'] || '{}')
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
                              class: 'availability-icon label label-default', title: 'Availability: Online',
                              'data-toggle' => 'tooltip')
          info << content_tag(:div, 'Online access is not currently available.', class: 'library-location')
        else
          info << content_tag(:span, 'Online', class: 'availability-icon label label-primary', title: 'Electronic access', 'data-toggle' => 'tooltip')
          info << links.shift.html_safe
        end
      else
        if holding['dspace']
          check_availability = false
          info << content_tag(:span, 'On-site access', class: 'availability-icon label label-success', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location Must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe if aeon_location?(location)
        elsif /^scsb.+/.match? location[:code]
          check_availability = false
          unless holding['items'].nil?
            scsb_multiple = true unless holding['items'].count == 1
            if scsb_supervised_items?(holding)
              info << content_tag(:span, 'On-site access', class: 'availability-icon label label-success', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
              info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe
            else
              info << content_tag(:span, '', class: 'availability-icon label', title: '', 'data-scsb-availability' => 'true', 'data-toggle' => 'tooltip', 'data-scsb-barcode' => holding['items'].first['barcode'].to_s).html_safe
            end
          end
        elsif holding['dspace'].nil?
          info << content_tag(:span, '', class: 'availability-icon').html_safe
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip', 'aria-hidden' => 'true').html_safe if aeon_location?(location)
        else
          check_availability = false
          info << content_tag(:span, 'Unavailable', class: 'availability-icon label label-danger', title: 'Availability: Material under embargo', 'data-toggle' => 'tooltip')
        end
        info << content_tag(:div, search_location_display(holding, document), class: 'library-location', data: { location: true, record_id: document['id'], holding_id: id })
      end
      block << content_tag(:li, info.html_safe, data: { availability_record: check_availability, record_id: document['id'], holding_id: id, aeon: aeon_location?(location) })
    end

    if scsb_multiple == true
      block << content_tag(:li, link_to('View Record for Full Availability', solr_document_path(document['id']), class: 'availability-icon label label-default more-info', title: 'Click on the record for full availability info', 'data-toggle' => 'tooltip').html_safe)
    elsif holdings_hash.length > 2
      block << content_tag(:li, link_to('View Record for Full Availability', solr_document_path(document['id']),
                                        class: 'availability-icon label label-default more-info', title: 'Click on the record for full availability info',
                                        'data-toggle' => 'tooltip').html_safe)

    elsif !holdings_hash.empty?
      block << content_tag(:li, link_to('', solr_document_path(document['id']),
                                        class: 'availability-icon more-info', title: 'Click on the record for full availability info',
                                        'data-toggle' => 'tooltip').html_safe, class: 'empty', data: { record_id: document['id'] })
    end
    if block.empty?
      content_tag(:div, t('blacklight.holdings.search_missing'))
    else
      content_tag(:ul, block.html_safe)
    end
  end

  def search_location_display(holding, document)
    location = holding_location_label(holding)
    render_arrow = (location.present? && holding['call_number'].present?)
    arrow = render_arrow ? ' &raquo; ' : ''
    cn_value = holding['call_number_browse'] || holding['call_number']
    locate_link = locate_link_with_glyph(holding['location_code'], document, cn_value, holding['library'])
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
    args[:document][args[:field]].each_with_index do |_subject, i|
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
  end

  def browse_name(args)
    args[:document][args[:field]].each_with_index do |name, i|
      newname = link_to(name, "/?f[author_s][]=#{CGI.escape name}", class: 'search-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{name}", title: "Search: #{name}") + '  ' +
                link_to('[Browse]', "/browse/names?q=#{CGI.escape name}", class: 'browse-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{name}", title: "Browse: #{name}", dir: name.dir.to_s)
      args[:document][args[:field]][i] = newname.html_safe
    end
  end

  def name_title(args)
    args[:document][args[:field]].each_with_index do |name_t, i|
      next unless args[:document]['name_title_browse_s']&.include?(name_t)
      newname_t = link_to(name_t, "/?f[name_title_browse_s][]=#{CGI.escape name_t}", class: 'search-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{name_t}", title: "Search: #{name_t}") + '  ' +
                  link_to('[Browse]', "/browse/name_titles?q=#{CGI.escape name_t}", class: 'browse-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{name_t}", title: "Browse: #{name_t}", dir: name_t.dir.to_s)
      args[:document][args[:field]][i] = newname_t.html_safe
    end
  end

  def link_to_search_value(args)
    if args[:document][args[:field]].present?
      args[:document][args[:field]].each_with_index do |field, i|
        field_link = link_to(field, "/?f[#{args[:field]}][]=#{CGI.escape field}", class: 'search-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{field}", title: "Search: #{field}")
        args[:document][args[:field]][i] = field_link
      end
    end
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
    "#{icon} #{formats}".html_safe
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

  def render_location_code(value)
    location = Bibdata.holding_locations[value.to_sym]
    location.nil? ? value : "#{value}: #{location_full_display(location)}"
  end

  def holding_location_label(holding)
    loc_code = holding['location_code']
    location = Bibdata.holding_locations[loc_code.to_sym] unless loc_code.nil?
    location.nil? ? holding['location'] : location_full_display(location)
  end

  #     location = Bibdata.holding_locations[value.to_sym]
  def location_full_display(loc)
    loc['label'] == '' ? loc['library']['label'] : loc['library']['label'] + ' - ' + loc['label']
  end

  def html_safe(args)
    args[:document][args[:field]].each_with_index { |v, i| args[:document][args[:field]][i] = v.html_safe }
  end

  def voyager_url(bibid)
    "https://catalog.princeton.edu/cgi-bin/Pwebrecon.cgi?BBID=#{bibid}"
  end

  def current_year
    DateTime.now.year
  end

  def scsb_note(args)
    args[:document][args[:field]].uniq
  end
  alias recap_note scsb_note

  # Construct an adapter for Solr Documents and the bib. data service
  # @return [HoldingRequestsAdapter]
  def holding_requests_adapter
    HoldingRequestsAdapter.new(@document, Bibdata)
  end
end
