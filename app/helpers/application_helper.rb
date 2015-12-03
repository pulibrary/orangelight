
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
      if add_marcit_holdings(url).empty?
        urls << link
      else
        urls << add_marcit_holdings(url)
      end
    end
    urls.html_safe
  end

  def add_marcit_holdings(url)
    if /getit\.princeton\.edu/.match(url)
      content_tag(:div, "", :id => "full_text", :class => ["availability--panel", "availability_full-text"] )
    else
      ""
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
      ' ' + link_to("[#{t('blacklight.holdings.stackmap')}]".html_safe, "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{bib}", :target => "_blank", class: "find-it", 'data-map-location' => "#{location}")
    end
  end

  def locate_link_with_gylph location, bib, library=nil
    if DONT_FIND_IT.include?(library)
      ''
    else
      ' ' + link_to("<span class=\"glyphicon glyphicon-map-marker\"></span>".html_safe, "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{bib}", :target => "_blank", title: t('blacklight.holdings.stackmap'), class: "find-it", 'data-map-location' => "#{location}")
    end
  end

  def holding_block args
    block = ''
    holdings_hash = JSON.parse(args[:document][args[:field]])
    holdings_hash.each do |id, holding|
      info = ''
      unless holding['location'].blank?
        location = "Location: #{holding['location']}"
        location << locate_link(holding['location_code'], args[:document]['id'], holding['library'])
        info << content_tag(:li, location.html_safe, class: 'library-location')
      end
      unless holding['call_number'].blank?
        cn_browse_link = link_to('[Browse]', "/browse/call_numbers?q=#{holding['call_number']}", class: 'browse-cn',
                            'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{holding['call_number']}",
                            title: "Browse: #{holding['call_number']}")
        cn = "Call Number: #{holding['call_number']} #{cn_browse_link}"
        info << content_tag(:li, cn.html_safe, class: 'holding-call-number')
      end
      block << content_tag(:li, content_tag(:ul, info.html_safe, holding_id: id), class: 'holding-block') unless info.empty?
    end
    content_tag(:ul, block.html_safe) unless block.empty?
  end

  def holding_request_block (holdings, doc_id)
    block = ''
    holdings_hash = JSON.parse(holdings)
    holdings_hash.each do |id, holding|
      render_arrow = !holding['library'].blank? and !holding['call_number'].blank?
      arrow = render_arrow ? ' &raquo; ' : ''
      info = ''
      unless holding['location'].blank?
        location = "#{holding['location']}"
        location << locate_link_with_gylph(holding['location_code'], doc_id, holding['library'])
        info << content_tag(:h3, location.html_safe, class: 'library-location')
      end
      unless holding['call_number'].blank?
        cn_browse_link = link_to('[Browse]', "/browse/call_numbers?q=#{holding['call_number']}", class: 'browse-cn',
                            'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{holding['call_number']}",
                            title: "Browse: #{holding['call_number']}")
        cn = "#{holding['call_number']} #{cn_browse_link}"
        info << content_tag(:span, cn.html_safe, class: 'holding-call-number')
      end
      block << content_tag(:div, content_tag(:span, "#{info}#{request_placeholder(doc_id, id)}".html_safe, {'holding_id' => id, 'data-holding-location_code' => holding['location_code']}), class: 'holding-block')unless info.empty?
    end
    content_tag(:div, block.html_safe) unless block.empty?
  end

  def request_placeholder(doc_id, holding_id)
    placeholder = ""
    placeholder << content_tag(:div, content_tag(:span, '', class: 'availability-icon').html_safe, {'data-availability-record' => true, 'data-record-id' => doc_id, 'data-holding-id' => holding_id}, class: 'holding-block')
    placeholder << "<div class=\"location-services\"><a target=\"_blank\" class=\"request btn btn-mini btn-primary\" href=\"/request\">Request</a></div>"
    placeholder
  end

  def holding_block_search args
    block = ''
    links = search_links(args[:document]['electronic_access_1display'])
    holdings_hash = JSON.parse(args[:document][args[:field]])
    holdings_hash.first(2).each do |id, holding|
      render_arrow = (!holding['library'].blank? and !holding['call_number'].blank?)
      arrow = render_arrow ? ' &raquo; ' : ''
      info = ''
      if holding['library'] == 'Online'
        if links.empty?
          info << content_tag(:span, 'LINK MISSING', class: 'label label-danger',
                              title: 'Electronic Access')
          info << ' Please contact public services about this error.'
        else
          info << content_tag(:span, 'ONLINE', class: 'availability-icon label label-primary',
                              title: 'Electronic Access')
          info << links.shift.html_safe
        end
      else
        info << content_tag(:span, '', class: 'availability-icon').html_safe
        info << "#{holding['library']}#{arrow}#{holding['call_number']}".html_safe
        info << locate_link(holding['location_code'], args[:document]['id'], holding['library']).html_safe
      end
      block << content_tag(:li, info.html_safe, data: { availability_record: true, record_id: args[:document]['id'], holding_id: id })
    end
    block << content_tag(:li, content_tag(:span, 'View Record for Full Availability', class: 'availability-icon label label-default',
                         title: 'Click on the record for full availability info').html_safe) if holdings_hash.length > 2
    content_tag(:ul, block.html_safe) unless block.empty?
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
    var = args[:document][args[:field]][0]
    "#{render_icon(var)} #{var}".html_safe
  end

  def voyager_url bibid
    "http://catalog.princeton.edu/cgi-bin/Pwebrecon.cgi?BBID=#{bibid}"
  end

end
