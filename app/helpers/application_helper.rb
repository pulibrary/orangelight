module ApplicationHelper
  include Requests::Pageable
  # First argument of link_to is optional display text. If null, the second argument
  # (URL) is the display text for the link.
  # Proxy Base is added to force remote access when appropriate
  def urlify(electronic_access)
    urls = ''
    links = JSON.parse(electronic_access)
    links.each do |url, text|
      link = link_to(text.first, "#{ENV['proxy_base']}#{url}", target: '_blank')
      link = "#{text[1]}: " + link if text[1]
      link = "<li>#{link}</li>" if links.count > 1
      if /getit\.princeton\.edu/ =~ url
        urls << content_tag(:div, '', :id => 'full_text', :class => ['availability--panel', 'availability_full-text'], 'data-umlaut-fulltext' => true)
      end
      urls << content_tag(:div, link.html_safe, class: 'electronic-access')
    end
    if links.count > 1
      content_tag(:ul, urls.html_safe)
    else
      urls.html_safe
    end
  end

  # Takes first 2 links for pairing with online holdings in search results
  def search_links(electronic_access)
    urls = []
    unless electronic_access.nil?
      links_hash = JSON.parse(electronic_access)
      links_hash.first(2).each do |url, text|
        link = link_to(text.first, "#{ENV['proxy_base']}#{url}", target: '_blank')
        link = "#{text[1]}: " + link if text[1]
        urls << link
      end
    end
    urls
  end

  DONT_FIND_IT = ['Fine Annex', 'Forrestal Annex', 'Mudd Manuscript Library', 'Online', 'Rare Books and Special Collections', 'ReCAP'].freeze
  def locate_link(location, bib, call_number, library = nil)
    if DONT_FIND_IT.include?(library) || call_number.blank?
      ''
    else
      ' ' + link_to(%(<span class="link-text">#{t('blacklight.holdings.stackmap')}</span> <span class="glyphicon glyphicon-map-marker"></span>).html_safe, "#{ENV['stackmap_base']}?loc=#{location}&id=#{bib}", :target => '_blank', class: 'find-it', 'data-map-location' => location.to_s, 'data-toggle' => 'tooltip')
    end
  end

  def locate_link_with_gylph(location, bib, call_number, library = nil)
    if DONT_FIND_IT.include?(library) || call_number.blank?
      ''
    else
      ' ' + link_to('<span class="glyphicon glyphicon-map-marker"></span>'.html_safe, "#{ENV['stackmap_base']}?loc=#{location}&id=#{bib}", :target => '_blank', title: t('blacklight.holdings.stackmap'), class: 'find-it', 'data-map-location' => location.to_s, 'data-toggle' => 'tooltip')
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
    links = urlify(document['electronic_access_1display'] || '{}')
    physical_holdings = ''
    online_holdings = ''
    is_journal = document['format'].include?('Journal')
    online_holdings << links
    holdings.each do |id, holding|
      if holding['location_code'].start_with?('elf')
        online_holdings << process_online_holding(holding, doc_id, id, links.empty?)
      elsif !holding['location_code'].blank?
        physical_holdings << process_physical_holding(holding, doc_id, id, is_journal)
      end
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

  def process_physical_holding(holding, bib_id, holding_id, is_journal)
    info = ''
    unless (holding_loc = holding_location_label(holding)).blank?
      location = content_tag(:span, holding_loc, class: 'location-text', data:
                            {
                              location: true,
                              holding_id: holding_id
                            }
                            )
      location << locate_link(holding['location_code'], bib_id, holding['call_number'], holding['library']).html_safe
      info << content_tag(:h3, location.html_safe, class: 'library-location')
    end
    unless holding['call_number'].blank?
      cn_value = holding['call_number_browse'] || holding['call_number']
      cn_browse_link = link_to(%(<span class="link-text">#{t('blacklight.holdings.browse')}</span> <span class="icon-bookslibrary"></span>).html_safe,
                               "/browse/call_numbers?q=#{CGI.escape cn_value}",
                               class: 'browse-cn', 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{cn_value}",
                               title: "Browse: #{cn_value}")
      cn = "#{holding['call_number']} #{cn_browse_link}"
      info << content_tag(:div, cn.html_safe, class: 'holding-call-number')
    end
    info << if holding['dspace']
              content_tag(:span, 'On-site access', class: 'availability-icon label label-warning',
                                                   title: 'Availability: On-site', 'data-toggle' => 'tooltip')
            else
              content_tag(:div, content_tag(:div, '', class: 'availability-icon').html_safe, class: 'holding-status', data: { 'availability_record' => true, 'record_id' => bib_id, 'holding_id' => holding_id })
            end
    info << content_tag(:div, "Copy number: #{holding['copy_number']}".html_safe, class: 'copy-number') unless holding['copy_number'].nil?
    info << content_tag(:ul, "#{holding_label('Shelving title:')} #{listify_array(holding['shelving_title'])}".html_safe, class: 'shelving-title') unless holding['shelving_title'].nil?
    info << content_tag(:ul, "#{holding_label('Location note:')} #{listify_array(holding['location_note'])}".html_safe, class: 'location-note') unless holding['location_note'].nil?
    info << content_tag(:ul, "#{holding_label('Location has:')} #{listify_array(holding['location_has'])}".html_safe, class: 'location-has') unless holding['location_has'].nil?
    info << content_tag(:ul, ''.html_safe, class: 'journal-current-issues', data: { journal: true, holding_id: holding_id }) if is_journal
    unless holding['dspace']
      location_rules = LOCATIONS[holding['location_code'].to_sym]
      info << request_placeholder(bib_id, holding_id, location_rules, holding).html_safe
    end
    info = content_tag(:div, info.html_safe, class: 'holding-block') unless info.empty?
    info
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

  def more_in_this_series_link(title)
    link_to('[More in this series]', "/catalog?q1=#{CGI.escape title}&f1=in_series&search_field=advanced",
            class: 'more-in-series', 'data-toggle' => 'tooltip',
            'data-original-title' => "More in series: #{title}", title: "More in series: #{title}",
            dir: title.dir.to_s)
  end

  def holding_label(label)
    content_tag(:div, label, class: 'holding-label')
  end

  def request_placeholder(doc_id, holding_id, location_rules, holding)
    content_tag(:div, class: 'location-services', data: { open: open_location?(location_rules, holding), aeon: aeon_location?(location_rules), holding_id: holding_id }) do
      if pageable?(holding)
        link_to 'Paging Request', "https://fulfill.princeton.edu/requests/#{doc_id}?mfhd=#{holding_id}", title: 'View Options to Request copies from this Location', target: '_blank', class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
      else
        link_to 'Request', "https://library.princeton.edu/requests/#{doc_id}?mfhd=#{holding_id}", title: 'View Options to Request copies from this Location', target: '_blank', class: 'request btn btn-xs btn-primary', data: { toggle: 'tooltip' }
      end
    end
  end

  def pageable?(holding)
    if paging_locations.include? holding['location_code']
      if holding.key?('call_number')
        if lc_number?(holding['call_number'])
          in_call_num_range(holding['call_number'], paging_ranges[holding['location_code']])
        end
      end
    end
  end

  def open_location?(location, holding)
    if pageable?(holding)
      false
    else
      location.nil? ? false : location[:open]
    end
  end

  def aeon_location?(location)
    location.nil? ? false : location[:aeon_location]
  end

  def holding_block_search(document)
    block = ''
    links = search_links(document['electronic_access_1display'])
    holdings_hash = JSON.parse(document['holdings_1display'] || '{}')
    holdings_hash.first(2).each do |id, holding|
      check_availability = true
      info = ''
      if holding['library'] == 'Online'
        check_availability = false
        if links.empty?
          check_availability = true
          info << content_tag(:span, 'Link Missing',
                              class: 'availability-icon label label-default', title: 'Availability: Online',
                              'data-toggle' => 'tooltip')
          info << 'Online access is not currently available.'
        else
          info << content_tag(:span, 'Online', class: 'availability-icon label label-primary', title: 'Electronic access', 'data-toggle' => 'tooltip')
          info << links.shift.html_safe
        end
      else
        if holding['dspace']
          check_availability = false
          info << content_tag(:span, 'On-site access', class: 'availability-icon label label-warning', title: 'Availability: On-site', 'data-toggle' => 'tooltip')
        else
          info << content_tag(:span, '', class: 'icon-warning', title: t('blacklight.holdings.paging_request'), 'data-toggle' => 'tooltip').html_safe if pageable?(holding)
          info << content_tag(:span, '', class: 'availability-icon').html_safe
        end
        info << content_tag(:div, search_location_display(holding, document), class: 'library-location', data: { location: true, record_id: document['id'], holding_id: id })
      end
      block << content_tag(:li, info.html_safe, data: { availability_record: check_availability, record_id: document['id'], holding_id: id })
    end
    if holdings_hash.length > 2
      block << content_tag(:li, link_to('View Record for Full Availability', catalog_path(document['id']),
                                        class: 'availability-icon label label-default more-info', title: 'Click on the record for full availability info',
                                        'data-toggle' => 'tooltip').html_safe)
    elsif !holdings_hash.empty?
      block << content_tag(:li, link_to(' ', catalog_path(document['id']),
                                        class: 'availability-icon more-info', title: 'Click on the record for full availability info',
                                        'data-toggle' => 'tooltip').html_safe, data: { record_id: document['id'] })
    end
    if block.empty?
      content_tag(:div, t('blacklight.holdings.search_missing'))
    else
      content_tag(:ul, block.html_safe)
    end
  end

  def search_location_display(holding, document)
    location = holding_location_label(holding)
    render_arrow = (!location.blank? && !holding['call_number'].blank?)
    arrow = render_arrow ? ' &raquo; ' : ''
    location_display = location + arrow + content_tag(:span, %(#{holding['call_number']}#{locate_link_with_gylph(holding['location_code'], document['id'], holding['call_number'], holding['library'])}).html_safe, class: 'call-number')
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

  def format_icon(args)
    icon = render_icon(args[:document][args[:field]][0]).to_s
    formats = format_render(args)
    "#{icon} #{formats}".html_safe
  end

  def format_render(args)
    args[:document][args[:field]].join(', ')
  end

  def render_location_code(value)
    location = LOCATIONS[value.to_sym]
    location.nil? ? value : "#{value}: #{location_full_display(location)}"
  end

  def holding_location_label(holding)
    loc_code = holding['location_code']
    location = LOCATIONS[loc_code.to_sym] unless loc_code.nil?
    location.nil? ? holding['location'] : location_full_display(location)
  end

  def location_full_display(loc)
    loc['label'] == '' ? loc['library']['label'] : loc['library']['label'] + ' - ' + loc['label']
  end

  def html_safe(args)
    args[:document][args[:field]].each_with_index { |v, i| args[:document][args[:field]][i] = v.html_safe }
  end

  def voyager_url(bibid)
    "http://catalog.princeton.edu/cgi-bin/Pwebrecon.cgi?BBID=#{bibid}"
  end
end
