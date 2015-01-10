
module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  RTL_RANGE = [0x590..0x8FF, 0xFB1D..0xFB44, 0xFB50..0xFDFF, 0xFE70..0xFEFF, 0x10800..0x10F00]
  CHECK_INDEXES = [0,5,11]


	def getdir(str, opts={})
	  opts.fetch(:check_indexes, CHECK_INDEXES).each do |i|
	    RTL_RANGE.each do |subrange|
	      if str[i]
	      	if subrange.cover?(str[i].unpack('U*0')[0])
	          return "rtl"
	        end
	      end
	    end
	  end
	  return "ltr"
	end 

  def left_anchor_strip solr_parameters, user_parameters 
    if solr_parameters[:q]
      if solr_parameters[:q].include?("{!qf=$left_anchor_qf pf=$left_anchor_pf}")
        newq = solr_parameters[:q].gsub("{!qf=$left_anchor_qf pf=$left_anchor_pf}", "")
        solr_parameters[:q] = "{!qf=$left_anchor_qf pf=$left_anchor_pf}" + newq.gsub(" ", "")
      end         
    end
  end

  # Returns suitable argument to options_for_select method, to create
  # an html select based on #search_field_list with labels for search
  # bar only. Skips search_fields marked :include_in_simple_select => false
  def search_bar_select
    blacklight_config.search_fields.collect do |key, field_def|
      [field_def.dropdown_label || field_def.label,  field_def.key] if should_render_field?(field_def)
    end.compact
  end


  def redirect_browse solr_parameters, user_parameters 
    if user_parameters[:search_field]
      if user_parameters[:search_field] == "browse_subject"
        redirect_to "/browse/subjects?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == "browse_cn"
        redirect_to "/browse/call_numbers?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      elsif user_parameters[:search_field] == "browse_name"
        redirect_to "/browse/names?search_field=#{user_parameters[:search_field]}&q=#{CGI.escape user_parameters[:q]}"
      else
        user_parameters[:model] = nil
        user_parameters[:rpp] = nil
      end  

    end
  end  

  # def altscript! values
  #   values.each_with_index do |contents, i|
  #     if getdir(contents) == "rtl"
  #       values[i] = ("<div dir=\"rtl\">" + contents + "</div>").html_safe
  #     end
  #   end
  # end

  # def render_value value=nil, field_config=nil
  #   safe_value = value.respond_to?(:force_encoding) ? value.force_encoding("UTF-8") : value

  #   if field_config and field_config.itemprop
  #     safe_value = content_tag :span, safe_value, :itemprop => field_config.itemprop 
  #   end
  #   safe_value
  # end  

  # no longer needs to be overriden
  # def presenter_class
  #   PrincetonPresenter
  # end
  
  # def render_document_show_field_value *args
  #   options = args.extract_options!
  #   document = args.shift || options[:document]

  #   field = args.shift || options[:field]
  #   presenter(document).render_document_show_field_value field, options
  # end

  class PrincetonPresenter < Blacklight::DocumentPresenter
    def field_value_separator
      "<br/>".html_safe
    end
  end
end