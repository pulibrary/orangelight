CHECK_INDEXES = [0,5,11]
LATIN_RANGE = 0..0x24F

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