module ApplicationHelper
  # def make_this_a_link options={}
  #   options[:document] # the original document
  #   options[:field] # the field to render
  #   options[:value] # the value of the field

  #   link_to options[:value], options[:value]
  # end

  def urlify args

    args[:document][args[:field]].each_with_index do |electronic_access, i|
        	args[:document][args[:field]][i] = link_to(electronic_access)
      end
  end

  def wheretofind args
  	args[:document][args[:field]].each_with_index do |location, i|
  		args[:document][args[:field]][i] = link_to("Locate", "http://library.princeton.edu/searchit/map?loc=#{location}&id=#{args[:document]["id"]}")
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

end
