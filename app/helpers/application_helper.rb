
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
    args[:document][args[:field]][0] = link_to(args[:document][args[:field]][1],
      args[:document][args[:field]][0], :target => "_blank")
  end

  def wheretofind args
  	args[:document][args[:field]].each_with_index do |location, i|
  		args[:document][args[:field]][i] = link_to("Locate", "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{args[:document]["id"]}", :target => "_blank")
  			# http://library.princeton.edu/locator/index.php?loc=#{location}&id=#{args[:document]["id"]}")
    end
  end

  def locate_link location, bib
    link_to("[Find it]", "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{bib}", :target => "_blank", class: "find-it")
  end


  def holding_block args
    args[:document][args[:field]].each_with_index do |call_numb, i|
      block = "<ul class='holding-block'><li>Call Number: #{call_numb}"
      block += '  '
      block += link_to('[Browse]', "/browse/call_numbers?q=#{call_numb}", class: "browse-cn", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{call_numb}", title: "Browse: #{call_numb}")
      block += "</li>"
      block += "<li>Location: #{args[:document]['location'][i]}"
      findit = locate_link(args[:document]['location_code_s'][i], args[:document]['id'])
      block += " #{findit}</li></ul>"
      args[:document][args[:field]][i] = block.html_safe
    end
  end

  def holding_block_search args
    if args[:document][args[:field]].size > 2
      return "Multiple Holdings"
    else
      args[:document][args[:field]].each_with_index do |call_numb, i|
        # block = "<dl class=holding-info><dt>Call Number:</dt> <dd>#{call_numb}</dd>"
        # block += "<dt>Location:</dt> <dd>#{args[:document]['location'][i]}"
        block = "#{call_numb} &raquo; #{args[:document]['location'][i]}"
        findit = locate_link(args[:document]['location_code_s'][i], args[:document]['id'])
        block += " #{findit}"
        args[:document][args[:field]][i] = block.html_safe
      end
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
          "/?f[subject_topic_facet][]=#{sub_array[i][j]}", class: "search-subject", 'data-toggle' => "tooltip", 'data-original-title' => "Search: #{sub_array[i][j]}", title: "Search: #{sub_array[i][j]}")
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
