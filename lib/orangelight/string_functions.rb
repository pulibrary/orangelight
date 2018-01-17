module StringFunctions
  class << self
    def cn_normalize(str)
      if /^[a-zA-Z]{2,3} \d+([qQ]?)$/ =~ str # the normalizer thinks "CD 104" is valid LC
        accession_number(str)
      else
        Lcsort.normalize(str.gsub(/x([A-Z])/, '\1')) || accession_number(str)
      end
    end

    def oclc_normalize(oclc, _opts = { prefix: false })
      oclc.gsub(/\D/, '').to_i.to_s
    end

    # Needed for name-title browse
    # https://github.com/traject/traject/blob/v2.3.1/lib/traject/macros/marc21.rb#L227
    def trim_punctuation(str)
      # If something went wrong and we got a nil, just return it
      return str unless str

      # trailing: comma, slash, semicolon, colon (possibly preceded and followed by whitespace)
      str = str.sub(%r{ *[ ,\/;:] *\Z}, '')

      # trailing period if it is preceded by at least three letters
      # (possibly preceded and followed by whitespace)
      str = str.sub(/( *\w\w\w)\. *\Z/, '\1')

      # single square bracket characters if they are the start and/or end
      #   chars and there are no internal square brackets.
      str = str.sub(/\A\[?([^\[\]]+)\]?\Z/, '\1')

      # trim any leading or trailing whitespace
      str.strip!

      str
    end

    private

    def accession_number(str)
      norm = str.upcase
      norm = norm.gsub(/(CD|DVD|LP|LS)-/, '\1') # should file together regardless of dash

      # normalize number to 7-digits, ignore oversize q
      norm.gsub(/(\d+)(Q?)$/) { format('%07d', Regexp.last_match[1].to_i) }
    end
  end
end
