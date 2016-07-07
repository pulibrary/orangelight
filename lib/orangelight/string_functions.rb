module StringFunctions
  class << self
    def cn_normalize(str)
      Lcsort.normalize(str) || str.upcase
    end

    def oclc_normalize(oclc, _opts = { prefix: false })
      oclc.gsub(/\D/, '').to_i.to_s
    end

    # traject - Marc21.trim_punctuation method
    def trim_punctuation(str)
      return str unless str
      str = str.sub(/ *[ ,\/;:] *\Z/, '')
      str = str.sub(/( *\w\w\w)\. *\Z/, '\1')
      str = str.sub(/\A\[?([^\[\]]+)\]?\Z/, '\1')
      str = str.strip
      str
    end
  end
end
