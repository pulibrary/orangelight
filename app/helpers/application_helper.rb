
module ApplicationHelper
  # def make_this_a_link options={}
  #   options[:document] # the original document
  #   options[:field] # the field to render
  #   options[:value] # the value of the field

  #   link_to options[:value], options[:value]
  # end

  # Creates link for electronic access URL, works only if one electronic access link.
  # First argument of link_to is optional display text. If null, the second argument
  # (URL) is the display text for the link.

  def urlify args
    urls = ''
    links = JSON.parse(args[:document][args[:field]])
    links.each do |url, text|
      link = link_to(text.first, url, :target => "_blank")
      link = "#{text[1]}: " + link if text[1]
      link = "<li>#{link}</li>" if links.count > 1
      urls << link
    end
    urls.html_safe
  end

  DONT_FIND_IT = ['Fine Annex', 'Forrestal Annex', 'Mudd Manuscript Library', 'Online', 'Rare Books and Special Collections', 'ReCAP']
  def locate_link location, bib, library=nil
    if DONT_FIND_IT.include?(library)
      ''
    else
      ' ' + link_to("[Find it]", "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{bib}", :target => "_blank", class: "find-it")
    end
  end

  def holding_block args
    block = ''
    holdings_hash = JSON.parse(args[:document][args[:field]])
    holdings_hash.each do |id, holding|
      info = ''
      unless holding['call_number'].blank?
        cn_browse_link = link_to('[Browse]', "/browse/call_numbers?q=#{holding['call_number']}", class: 'browse-cn',
                            'data-toggle' => "tooltip", 'data-original-title' => "Browse: #{holding['call_number']}",
                            title: "Browse: #{holding['call_number']}")
        cn = "Call Number: #{holding['call_number']} #{cn_browse_link}"
        info << content_tag(:li, cn.html_safe, class: 'holding-call-number')
      end
      unless holding['location'].blank?
        location = "Location: #{holding['location']}"
        location << locate_link(holding['location_code'], args[:document]['id'], holding['library'])
        info << content_tag(:li, location.html_safe, class: 'library-location')
      end
      block << content_tag(:li, content_tag(:ul, info.html_safe, holding_id: id), class: 'holding-block') unless info.empty?
    end
    content_tag(:ul, block.html_safe) unless block.empty?
  end

  def holding_block_search args
    block = ''
    holdings_hash = JSON.parse(args[:document][args[:field]])
    holdings_hash.first(2).each do |id, holding|
      render_arrow = !holding['library'].blank? and !holding['call_number'].blank?
      arrow = render_arrow ? ' &raquo; ' : ''
      info = content_tag(:span, '', class: 'availability-icon').html_safe
      info << "#{holding['library']}#{arrow}#{holding['call_number']}".html_safe
      info << locate_link(holding['location_code'], args[:document]['id'], holding['library']).html_safe
      block << content_tag(:li, info.html_safe, data: { availability_record: true, record_id: args[:document]['id'], holding_id: id })
    end
    block << content_tag(:li, content_tag(:span, 'View Record for Full Availability', class: 'availability-icon label label-default',
                         title: 'Click on the record for full availability info').html_safe) if holdings_hash.length > 2
    content_tag(:ul, block.html_safe) unless block.empty?
    # if args[:document][args[:field]].size > 2
    #   block = content_tag(:span, 'View Record for Availability', class: 'availability-icon label label-default', title: 'Click on the record for full availability info').html_safe
    #   return "#{block}".html_safe
    # else
    #   args[:document][args[:field]].each_with_index do |call_numb, i|
    #     record_block = content_tag(:span,
    #                                data:
    #                                {
    #                                  availability_record: true,
    #                                  record_id: args[:document]['id'],
    #                                  loc_code: "#{args[:document]['location_code_s'][i]}"
    #                                }
    #                               ) do
    #       block = content_tag(:span, '', class: 'availability-icon').html_safe
    #       block += "#{call_numb} &raquo; ".html_safe
    #       block += "#{args[:document]['location'][i]}"
    #       findit = locate_link(args[:document]['location_code_s'][i], args[:document]['id'])
    #       block += " #{findit}".html_safe
    #       block.html_safe
    #     end
    #     args[:document][args[:field]][i] = record_block.html_safe
    #   end
    # end
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

  def browse_related_name args
    args[:document][args[:field]].each_with_index do |name, i|
      rel_term =  /^.*：/.match(name) ? /^.*：/.match(name)[0] : ''
      rel_name = name.gsub(/^.*：/,'')
      newname = rel_term + link_to(rel_name, "/?f[author_s][]=#{rel_name}") + '  ' + link_to('[Browse]', "/browse/names?q=#{rel_name}", class: "browse-related-name", dir: "#{getdir(rel_name)}")
      args[:document][args[:field]][i] = newname.html_safe
    end
  end



  def multiple_locations args
    if args[:document][args[:field]][1]
      args[:document][args[:field]] = ["Multiple Locations"]
    else
      args[:document][args[:field]][0]
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
