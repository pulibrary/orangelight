	# LATIN SCRIPT UNICODE RANGES
	#########################################################
    # Basic Latin, 0000–007F. This block corresponds to ASCII.
    # Latin-1 Supplement, 0080–00FF
    # Latin Extended-A, 0100–017F
    # Latin Extended-B, 0180–024F
    # IPA Extensions, 0250–02AF
    # Spacing Modifier Letters, 02B0–02FF
    # Phonetic Extensions, 1D00–1D7F
    # Phonetic Extensions Supplement, 1D80–1DBF
    # Latin Extended Additional, 1E00–1EFF
    # Superscripts and Subscripts, 2070-209F
    # Letterlike Symbols, 2100–214F
    # Number Forms, 2150–218F
    # Latin Extended-C, 2C60–2C7F
    # Latin Extended-D, A720–A7FF
    # Latin Extended-E, AB30–AB6F
    # Alphabetic Presentation Forms (Latin ligatures) FB00–FB4F
    # Halfwidth and Fullwidth Forms (fullwidth Latin letters) FF00–FFEF





CHECK_INDEXES = [0,5,11]
LATIN_RANGES = [0..0x2FF, 0x1D00..0x1DBF, 0x1E00..0x1EFF, 0x2070..0x209F, 0x2100..0x218F, 0x2C60..0x2C7F, 0xA720..0xA7FF, 0xAB30..0xAB6F, 0xFB00..0xFB4F, 0xFF00..0xFFEF]
RTL_RANGE = [0x590..0x8FF, 0xFB1D..0xFB44, 0xFB50..0xFDFF, 0xFE70..0xFEFF, 0x10800..0x10F00]

LATIN_RANGE = 0..0x2FF

module StringFunctions
  class << self
    def islatin(str, opts={})
      opts.fetch(:check_indexes, CHECK_INDEXES).each do |i|
        if str[i]
          if !LATIN_RANGE.cover?(str[i].unpack('U*0')[0])
            return false 
          end
        end      
      end
      return true
    end

    def charlatin(ch)
    	LATIN_RANGES.each do |subrange|
    		return true if subrange.cover?(ch.unpack('U*0')[0])
    	end
    	return false
    end



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
  end
end