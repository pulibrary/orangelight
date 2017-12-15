module ApplicationHelper
  include Requests::Aeon
  require './lib/orangelight/string_functions'

  # First argument of link_to is optional display text. If null, the second argument
  # (URL) is the display text for the link.
  # Proxy Base is added to force remote access when appropriate
  def urlify(electronic_access, document)
    urls = ''
    links = JSON.parse(electronic_access)
    links.each do |url, text|
      link = if /Open access/ =~ text.first
               link_to(text.first, url.to_s, target: '_blank')
             else
               link_to(text.first, "#{ENV['proxy_base']}#{url}", target: '_blank')
             end
      link = "#{text[1]}: " + link if text[1]
      link = "<li>#{link}</li>" if links.count > 1
      if /getit\.princeton\.edu/ =~ url
        marcit_ctx = url.gsub('http://getit.princeton.edu/resolve?', '') # strip to get only the query_string
        urls << content_tag(:div, '', :id => 'full_text', :class => ['availability--panel', 'availability_full-text'], 'data-umlaut-full-text' => true, 'data-url-marcit' => marcit_ctx)
      end
      urls << content_tag(:div, link.html_safe, class: 'electronic-access')
    end
    unless links.keys.any? { |link| /getit\.princeton\.edu/.match(link) } || links.empty? || !document.umlaut_fulltext_eligible?
      urls << content_tag(:div, '', :id => 'full_text', :class => ['availability--panel', 'availability_full-text', 'availability_full-text-alternative'], 'data-umlaut-services' => true)
    end
    if links.count > 1
      content_tag(:ul, urls.html_safe)
    else
      urls.html_safe
    end
  end

  def umlaut_services_fulltext(document)
    services = ''
    unless document.key? 'electronic_access_1display'
      services << content_tag(:div, '', :id => 'full_text', :class => ['availability--panel', 'availability_full-text', 'availability--panel_umlaut'], 'data-umlaut-full-text' => true)
    end
    services.html_safe
  end

  def umlaut_services
    services = ''
    services << content_tag(:div, '', :id => 'excerpts', :class => ['availability--panel', 'availability_excerpts', 'availability--panel_umlaut'], 'data-umlaut-services' => true)
    services << content_tag(:div, '', :id => 'highlighted_link', :class => ['availability--panel', 'availability_highlighted-link', 'availability--panel_umlaut'], 'data-umlaut-services' => true)
    services.html_safe
  end

  # Takes first 2 links for pairing with online holdings in search results
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

  DONT_FIND_IT = ['Fine Annex', 'Forrestal Annex', 'Mudd Manuscript Library', 'Online', 'Rare Books and Special Collections', 'ReCAP'].freeze
  def locate_link(location, call_number, library)
    link = locate_url(location, @document, call_number, library)
    if link.nil?
      ''
    else
      ' ' + link_to(%(<span class="link-text">#{t('blacklight.holdings.stackmap')}</span><span class="glyphicon glyphicon-map-marker"></span>).html_safe, link, :target => '_blank', title: t('blacklight.holdings.stackmap'), class: 'find-it', 'data-map-location' => location.to_s, 'data-toggle' => 'tooltip')
    end
  end

  def locate_link_with_glyph(location, document, call_number, library)
    link = locate_url(location, document, call_number, library)
    if link.nil?
      ''
    else
      ' ' + link_to('<span class="glyphicon glyphicon-map-marker"></span>'.html_safe, link, :target => '_blank', title: t('blacklight.holdings.stackmap'), class: 'find-it', 'data-map-location' => location.to_s, 'data-toggle' => 'tooltip')
    end
  end

  def locate_url(location, document, call_number, library = nil)
    unless DONT_FIND_IT.include?(library) || call_number.nil?
      ::StackmapService::Url.new(document: document, loc: location, cn: call_number).url
    end
  end

  # holding record fields: 'location', 'library', 'location_code', 'call_number', 'call_number_browse',
  # 'shelving_title', 'location_note', 'electronic_access_1display', 'location_has', 'location_has_current',
  # 'indexes', 'supplements'
  # process online and physical holding information at the same time
  # @param [SolrDocument] document - record display fields
  # @return [String] online - online holding info html
  # @return [String] physical - physical holding info html
  def holding_request_block(document)
    doc_id = document['id']
    holdings = JSON.parse(document['holdings_1display'] || '{}')
    links = urlify(document['electronic_access_1display'] || '{}', document)
    physical_holdings = ''
    online_holdings = ''
    is_journal = document.fetch('format', []).include?('Journal')
    pub_date = document.key?('pub_date_start_sort') ? document['pub_date_start_sort'] : 0
    online_holdings << links
    elf_holdings, other_holdings = holdings.partition { |_id, h| h['location_code'].start_with?('elf') }
    elf_holdings.each do |id, holding|
      online_holdings << process_online_holding(holding, doc_id, id, links.empty?)
    end
    other_holdings.sort_by { |_id, h| Bibdata.holding_locations.keys.index(h['location_code']) }.each do |id, holding|
      physical_holdings << process_physical_holding(holding, doc_id, id, is_journal, pub_date)
    end
    online = content_tag(:div, online_holdings.html_safe) unless online_holdings.empty?
    physical = content_tag(:div, physical_holdings.html_safe) unless physical_holdings.empty?
    physical = missing_holdings if physical.nil? && online.nil?
    [online, physical]
  end

  def process_online_holding(_holding, bib_id, holding_id, link_missing)
    info = ''
    if link_missing
      info << content_tag(:span, 'Link Missing', class: 'availability-icon label label-default',
                                                 title: 'Availability: Online', 'data-toggle' => 'tooltip')
      info = content_tag(:div, info.html_safe, class: 'holding-block', data: { availability_record: true, record_id: bib_id, holding_id: holding_id })
    end
    info
  end

  def missing_holdings
    content_tag(:div, t('blacklight.holdings.missing'), class: 'holding-block')
  end

  def process_physical_holding(holding, bib_id, holding_id, is_journal, pub_date)
    info = ''
    location_rules = Bibdata.holding_locations[holding['location_code'].to_sym]
    cn_value = holding['call_number_browse'] || holding['call_number']
    if (holding_loc = holding_location_label(holding)).present?
      location = content_tag(:span, holding_loc, class: 'location-text', data:
                            {
                              location: true,
                              holding_id: holding_id
                            })
      location << locate_link(holding['location_code'], cn_value, holding['library']).html_safe
      info << content_tag(:h3, location.html_safe, class: 'library-location', data: { holding_id: holding_id })
    end
    unless cn_value.nil?
      cn_browse_link = link_to(%(<span class="link-text">#{t('blacklight.holdings.browse')}</span> <span class="icon-bookslibrary"></span>).html_safe,
                               "/browse/call_numbers?q=#{CGI.escape cn_value}",
                               class: 'browse-cn', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{cn_value}",
                               title: "Browse: #{cn_value}")
      cn = "#{holding['call_number']} #{cn_browse_link}"
      info << content_tag(:div, cn.html_safe, class: 'holding-call-number')
    end
    info << if holding['dspace']
              content_tag(:span, 'On-site access', class: 'availability-icon label label-warning',
                                                   title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
            elsif /^scsb.+/ =~ holding['location_code']
              unless holding['items'].nil?
                content_tag(:div, content_tag(:span, '', title: '', class: 'availability-icon label', data: { toggle: 'tooltip' }).html_safe, class: 'holding-status', data: { 'availability_record' => true, 'record_id' => bib_id, 'holding_id' => holding_id, 'scsb-barcode' => holding['items'].first['barcode'], 'aeon' => recap_supervised_items?(holding) })
              end
            elsif holding['dspace'].nil?
              content_tag(:div, content_tag(:div, '', class: 'availability-icon').html_safe, class: 'holding-status', data: { 'availability_record' => true, 'record_id' => bib_id, 'holding_id' => holding_id, aeon: aeon_location?(location_rules) })
            else
              content_tag(:span, 'Unavailable', class: 'availability-icon label label-danger',
                                                title: 'Availability: Embargoed', 'data-toggle' => 'tooltip')
            end
    info << content_tag(:ul, "#{holding_label('Shelving title:')} #{listify_array(holding['shelving_title'])}".html_safe, class: 'shelving-title') unless holding['shelving_title'].nil?
    info << content_tag(:ul, "#{holding_label('Location note:')} #{listify_array(holding['location_note'])}".html_safe, class: 'location-note') unless holding['location_note'].nil?
    info << content_tag(:ul, "#{holding_label('Location has:')} #{listify_array(holding['location_has'])}".html_safe, class: 'location-has') unless holding['location_has'].nil?
    info << content_tag(:ul, ''.html_safe, class: 'journal-current-issues', data: { journal: true, holding_id: holding_id }) if is_journal
    # Label SCSB Use Restrictions
    if /^scsb.+/ =~ holding['location_code']
      info << recap_item_list(holding) unless holding['items'].nil?
    end
    unless holding_id == 'thesis' && pub_date > 2012
      info << request_placeholder(bib_id, holding_id, location_rules, holding).html_safe
    end
    info = content_tag(:div, info.html_safe, class: 'holding-block') unless info.empty?
    info
  end

  def recap_item_list(holding)
    restricted_items = holding['items'].map do |item|
      if item['use_statement'].present?
        content_tag(:li, title: recap_use_toolip(item['use_statement']), 'data-toggle' => 'tooltip') do
          content_tag(:span, recap_use_label(item['use_statement']), class: 'icon-warning icon-request-reading-room').html_safe
        end
      end
    end
    restricted_items.compact!
    if restricted_items.empty?
      ''
    else
      restricted_items.uniq!
      content_tag(:ul, "#{holding_label('Use Restrictions:')} #{restricted_items.join}".html_safe, class: 'item-list')
    end
  end

  def recap_use_label(restriction)
    "#{restriction} Only"
  end

  def recap_use_toolip(restriction)
    if restriction == 'In Library Use'
      t('blacklight.scsb.in_library_use')
    else
      t('blacklight.scsb.supervised_use')
    end
  end

  def recap_supervised_items?(holding)
    if holding.key? 'items'
      restricted_items = holding['items'].select { |item| item['use_statement'] == 'Supervised Use' }
      restricted_items.count == holding['items'].count
    else
      false
    end
  end

  def listify_array(arr)
    arr = arr.map do |e|
      content_tag(:li, e)
    end
    arr.join
  end

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

  def series_results(args)
    series_display =
      if params[:f1] == 'in_series'
        same_series_result(params[:q1], args[:document][args[:field]])
      else
        args[:document][args[:field]]
      end
    args[:document][args[:field]] = series_display.join(', ')
  end

  def same_series_result(series, series_display)
    series_display.select { |t| t.start_with?(series) }
  end

  def more_in_this_series_link(title)
    no_parens = title.gsub(/[()]/, '')
    link_to('[More in this series]', "/catalog?q1=#{CGI.escape no_parens}&f1=in_series&search_field=advanced",
            class: 'more-in-series', 'data-toggle' => 'tooltip',
            'data-original-title' => "More in series: #{title}", title: "More in series: #{title}",
            dir: title.dir.to_s)
  end

  def holding_label(label)
    content_tag(:div, label, class: 'holding-label')
  end

  def request_placeholder(doc_id, holding_id, location_rules, holding)
    content_tag(:div, class: "location-services #{show_request(location_rules, holding_id)}", data: { open: open_location?(location_rules), requestable: requestable_location?(location_rules), aeon: aeon_location?(location_rules), holding_id: holding_id }) do
      if /^scsb.+/ =~ location_rules['code']
        if recap_supervised_items?(holding)
          link_to 'Reading Room Request', "/requests/#{doc_id}?source=pulsearch", title: 'Request to view in Reading Room', class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
        else
          link_to request_label(location_rules), "/requests/#{doc_id}?source=pulsearch", title: request_tooltip(location_rules), class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
        end
      elsif non_voyager?(holding_id)
        link_to 'Reading Room Request', "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch", title: 'Request to view in Reading Room', class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
      else
        link_to request_label(location_rules), "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch", title: request_tooltip(location_rules), class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
      end
    end
  end

  def request_label(location_rules)
    if aeon_location?(location_rules)
      'Reading Room Request'
    else
      'Request'
    end
  end

  def request_tooltip(location_rules)
    if aeon_location?(location_rules)
      'Request to view in Reading Room'
    else
      'View Options to Request copies from this Location'
    end
  end

  def show_request(location_rules, holding_id)
    if non_voyager?(holding_id) || aeon_location?(location_rules) || /^scsb.+/ =~ location_rules['code']
      'service-always-requestable'
    else
      'service-conditional'
    end
  end

  def open_location?(location)
    location.nil? ? false : location[:open]
  end

  def requestable_location?(location)
    location.nil? ? false : location[:requestable]
  end

  def aeon_location?(location)
    location.nil? ? false : location[:aeon_location]
  end

  def holding_location(holding)
    location_code = holding.fetch('location_code', '').to_sym
    resolved_location = Bibdata.holding_locations[location_code]
    resolved_location ? resolved_location : {}
  end

  def holding_block_search(document)
    block = ''
    links = search_links(document['electronic_access_1display'])
    holdings_hash = JSON.parse(document['holdings_1display'] || '{}')
    scsb_multiple = false
    holdings_hash.first(2).each do |id, holding|
      location = holding_location(holding)
      check_availability = true
      info = ''
      if holding['library'] == 'Online'
        check_availability = false
        if links.empty?
          check_availability = true
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
          info << content_tag(:span, 'On-site access', class: 'availability-icon label label-warning', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location Must be requested', 'data-toggle' => 'tooltip').html_safe if aeon_location?(location)
        elsif /^scsb.+/ =~ location[:code]
          check_availability = false
          unless holding['items'].nil?
            scsb_multiple = true unless holding['items'].count == 1
            if recap_supervised_items?(holding)
              info << content_tag(:span, 'On-site access', class: 'availability-icon label label-success', title: 'Availability: On-site by request', 'data-toggle' => 'tooltip')
              info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip').html_safe
            else
              info << content_tag(:span, '', class: 'availability-icon label', title: '', 'data-scsb-availability' => 'true', 'data-toggle' => 'tooltip', 'data-scsb-barcode' => holding['items'].first['barcode'].to_s).html_safe
            end
          end
        elsif holding['dspace'].nil?
          info << content_tag(:span, '', class: 'availability-icon').html_safe
          info << content_tag(:span, '', class: 'icon-warning icon-request-reading-room', title: 'Items at this location must be requested', 'data-toggle' => 'tooltip').html_safe if aeon_location?(location)
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
        lnk_accum = lnk + t(SEPARATOR, class: 'subject-level')
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
      next unless args[:document]['name_title_browse_s'] && args[:document]['name_title_browse_s'].include?(name_t)
      newname_t = link_to(name_t, "/?f[name_title_browse_s][]=#{CGI.escape name_t}", class: 'search-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{name_t}", title: "Search: #{name_t}") + '  ' +
                  link_to('[Browse]', "/browse/name_titles?q=#{CGI.escape name_t}", class: 'browse-name-title', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{name_t}", title: "Browse: #{name_t}", dir: name_t.dir.to_s)
      args[:document][args[:field]][i] = newname_t.html_safe
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
        if i == 0
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
    args[:document][args[:field]] = all_links
  end

  def formats_to_exclude(document)
    holding_id = JSON.parse(document[:holdings_1display]).first[0] if document[:holdings_1display]
    if non_voyager?(holding_id) || document['id'].start_with?('SCSB')
      %i[marc marcxml refworks_marc_txt endnote openurl_ctx_kev]
    else
      []
    end
  end

  def format_icon(args)
    icon = render_icon(args[:document][args[:field]][0]).to_s
    formats = format_render(args)
    "#{icon} #{formats}".html_safe
  end

  def format_render(args)
    args[:document][args[:field]].join(', ')
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

  def recap_note(args)
    args[:document][args[:field]].uniq
  end
end
