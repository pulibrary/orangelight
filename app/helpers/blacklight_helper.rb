
module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior
  RTL_RANGE = [0x590..0x8FF, 0xFB1D..0xFB44, 0xFB50..0xFDFF, 0xFE70..0xFEFF, 0x10800..0x10F00]
  RTL_CHECK_INDEXES = [0,5,11]

	def getdir(str, opts={})
	  opts.fetch(:check_indexes, RTL_CHECK_INDEXES).each do |i|
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

  def presenter_class
    PrincetonPresenter
  end
  
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