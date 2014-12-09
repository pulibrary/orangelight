
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

  def relatedor document, field
  	# document[field].each_with_index do |related_name, i|
  	# 	document[field][i] = 'ho'
  	# end
   #  # document[]].each_with_index do |relator, i|
   #  #     	args[:document][args[:field]][i] = content_tag(:p, relator)
   #  # end  	
  	# # document[field][0] = 'hi'
  	# return content_tag(:dt, 'do').html_safe
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
          "/?f[subject_topic_facet][]=#{sub_array[i][j]}")
        lnk_accum = lnk + SEPARATOR
        full_sub = sub_array[i][j]
      end
      lnk += '  '
      lnk += link_to('[Browse]', "/browse/subjects?val=#{full_sub}", style: "font-size:10px; font-style:italic")
      args[:document][args[:field]][i] = lnk.html_safe        
    end


  end

  def browse_name args
    args[:document][args[:field]].each_with_index do |name, i|
      newname = link_to(name, "/?f[author_s][]=#{name}") + '  ' + link_to('[Browse]', "/browse/names?val=#{name}", style: "font-size:10px; font-style:italic")
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

end
