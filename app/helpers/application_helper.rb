module ApplicationHelper


  # First argument of link_to is optional display text. If null, the second argument
  # (URL) is the display text for the link.
  # Proxy Base is added to force remote access when appropriate
  def urlify electronic_access
    urls = ''
    links = JSON.parse(electronic_access)
    links.each do |url, text|
      link = link_to(text.first, "#{ENV['proxy_base']}#{url}", :target => "_blank")
      link = "#{text[1]}: " + link if text[1]
      link = "<li>#{link}</li>" if links.count > 1
      if /getit\.princeton\.edu/.match(url)
        urls << content_tag(:div, "", :id => "full_text", :class => ["availability--panel", "availability_full-text"], 'data-umlaut-fulltext' => true )
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
  def search_links electronic_access
    urls = []
    unless electronic_access.nil?
      links_hash = JSON.parse(electronic_access)
      links_hash.first(2).each do |url, text|
        link = link_to(text.first, "#{ENV['proxy_base']}#{url}", :target => "_blank")
        link = "#{text[1]}: " + link if text[1]
        urls << link
      end
    end
    urls
  end

  DONT_FIND_IT = ['Fine Annex', 'Forrestal Annex', 'Mudd Manuscript Library', 'Online', 'Rare Books and Special Collections', 'ReCAP']
  def locate_link location, bib, library=nil
    if DONT_FIND_IT.include?(library)
      ''
    else
      ' ' + link_to("[#{t('blacklight.holdings.stackmap')}]".html_safe, "#{ENV['stackmap_base']}?loc=#{location}&id=#{bib}", :target => "_blank", class: "find-it", 'data-map-location' => "#{location}", 'data-toggle' => "tooltip")
    end
  end

  def locate_link_with_gylph location, bib, library=nil
    if DONT_FIND_IT.include?(library)
      ''
    else
      ' ' + link_to("<span class=\"glyphicon glyphicon-map-marker\"></span>".html_safe, "#{ENV['stackmap_base']}?loc=#{location}&id=#{bib}", :target => "_blank", title: t('blacklight.holdings.stackmap'), class: "find-it", 'data-map-location' => "#{location}", 'data-toggle' => "tooltip")
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
    physical = missing_holdings if physical.nil? and online.nil?
    [online, physical]
  end

  def process_online_holding(holding, bib_id, holding_id, link_missing)
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
    unless holding['location'].blank?
      location = content_tag(:span, holding['location'], class: 'location-text', data: 
        { 
          location: true, 
          holding_id: holding_id
        }
      )
      location << locate_link_with_gylph(holding['location_code'], bib_id, holding['library']).html_safe
      info << content_tag(:h3, location.html_safe, class: 'library-location')
    end
    unless holding['call_number'].blank?
      cn_browse_link = link_to('[Browse]', "/browse/call_numbers?q=#{holding['call_number_browse']}", class: 'browse-cn',
                          'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{holding['call_number_browse']}",
                          title: "Browse: #{holding['call_number_browse']}")
      cn = "#{holding['call_number']} #{cn_browse_link}"
      info << content_tag(:div, cn.html_safe, class: 'holding-call-number')
    end
    if holding['dspace']
      info << content_tag(:span, 'On-site access', class: 'availability-icon label label-warning',
                          title: 'Availability: On-site', 'data-toggle' => 'tooltip')
    else
      info << content_tag(:div, content_tag(:div, '', class: 'availability-icon').html_safe, class: 'holding-status', data: { 'availability_record' => true, 'record_id' => bib_id, 'holding_id' => holding_id })
    end
    info << content_tag(:ul, "#{holding_label('Shelving title:')} #{listify_array(holding['shelving_title'])}".html_safe, class: 'shelving-title') unless holding['shelving_title'].nil?
    info << content_tag(:ul, "#{holding_label('Location note:')} #{listify_array(holding['location_note'])}".html_safe, class: 'location-note') unless holding['location_note'].nil?
    info << content_tag(:ul, "#{holding_label('Location has:')} #{listify_array(holding['location_has'])}".html_safe, class: 'location-has') unless holding['location_has'].nil?
    info << content_tag(:ul, ''.html_safe, class: 'journal-current-issues', data: { journal: true, holding_id: holding_id }) if is_journal
    unless holding['dspace']
      location_rules = LOCATIONS[holding['location_code'].to_sym]
      info << request_placeholder(bib_id, holding_id, location_rules).html_safe
    end
    info = content_tag(:div, info.html_safe, class: 'holding-block') unless info.empty?
    info
  end

  def listify_array(arr)
    arr = arr.map do |e|
      content_tag(:li, e)
    end
    arr = arr.join
  end

  def holding_label(label)
    content_tag(:div, label, class: 'holding-label')
  end

  def request_placeholder(doc_id, holding_id, location_rules)
    content_tag(:div, class: 'location-services', data: { open: location_rules[:open], aeon: location_rules[:aeon_location], holding_id: holding_id }) do
      link_to "Request", "/request/#{doc_id}?mfhd=#{holding_id}", title: "View Options to Request copies from this Location", target: "_blank", class: "request btn btn-xs btn-primary", data: { toggle: "tooltip" }
    end
  end

  def holding_block_search document
    block = ''
    links = search_links(document['electronic_access_1display'])
    holdings_hash = JSON.parse(document['holdings_1display'] || '{}')
    holdings_hash.first(2).each do |id, holding|
      check_availability = true
      render_arrow = (!holding['library'].blank? and !holding['call_number'].blank?)
      arrow = render_arrow ? ' &raquo; ' : ''
      info = ''
      if holding['library'] == 'Online'
        check_availability = false
        if links.empty?
          check_availability = true
          info << content_tag(:span, 'Link Missing', class: 'availability-icon label label-default',
                              title: 'Availability: Online', 'data-toggle' => 'tooltip')
          info << 'Online access is not currently available.'
        else
          info << link_to('Online', catalog_path(document['id']), class: 'availability-icon label label-primary',
                          title: 'Electronic access')
          info << links.shift.html_safe
        end
      else
        if holding['dspace']
          check_availability = false
          info << link_to('On-site access', catalog_path(document['id']), class: 'availability-icon label label-warning',
                          title: 'Availability: On-site')
        else
          info << link_to('', catalog_path(document['id']), class: 'availability-icon').html_safe
        end
        info << content_tag(:span, holding['library'], class: 'library-location', data: { location: true, record_id: document['id'], holding_id: id })
        info << "#{arrow}#{holding['call_number']}".html_safe
        info << locate_link_with_gylph(holding['location_code'], document['id'], holding['library']).html_safe
      end
      block << content_tag(:li, info.html_safe, data: { availability_record: check_availability, record_id: document['id'], holding_id: id })
    end
    if holdings_hash.length > 2
      block << content_tag(:li, link_to('View Record for Full Availability', catalog_path(document['id']),
                           class: 'availability-icon label label-default', title: 'Click on the record for full availability info',
                           'data-toggle' => 'tooltip').html_safe)
    elsif holdings_hash.length != 0
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

  SEPARATOR = '—'
  QUERYSEP = '—'
  def subjectify args

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
    linked_subsubjects = ''
    args[:document][args[:field]].each_with_index do |subject, i|
      lnk = ''
      lnk_accum = ''
      full_sub = ''
      all_subjects[i].each_with_index do |subsubject, j|
        lnk = lnk_accum + link_to(subsubject,
          "/?f[subject_facet][]=#{sub_array[i][j]}", class: "search-subject", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{sub_array[i][j]}", title: "Search: #{sub_array[i][j]}")
        lnk_accum = lnk + t(SEPARATOR, class: "subject-level")
        full_sub = sub_array[i][j]
      end
      lnk += '  '
      lnk += link_to('[Browse]', "/browse/subjects?q=#{full_sub}", class: "browse-subject", 'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{full_sub}", title: "Browse: #{full_sub}", dir: "#{getdir(full_sub)}")
      args[:document][args[:field]][i] = lnk.html_safe
    end


  end

  def browse_name args
    args[:document][args[:field]].each_with_index do |name, i|
      newname = link_to(name, "/?f[author_s][]=#{name}", class: "search-name", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{name}", title: "Search: #{name}") + '  ' + link_to('[Browse]', "/browse/names?q=#{name}", class: "browse-name", 'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{name}", title: "Browse: #{name}", dir: "#{getdir(name)}")
      args[:document][args[:field]][i] = newname.html_safe
    end
  end

  def format_icon args
    icon = "#{render_icon(args[:document][args[:field]][0])}"
    formats = format_render(args)
    "#{icon} #{formats}".html_safe
  end

  def format_render args
    args[:document][args[:field]].join(', ')
  end

  def html_safe args
    args[:document][args[:field]].each_with_index { |v, i| args[:document][args[:field]][i] = v.html_safe }
  end

  def voyager_url bibid
    "http://catalog.princeton.edu/cgi-bin/Pwebrecon.cgi?BBID=#{bibid}"
  end

end
