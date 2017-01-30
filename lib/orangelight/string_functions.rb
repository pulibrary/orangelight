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

    private

    def accession_number(str)
      norm = str.upcase
      norm = norm.gsub(/(CD|DVD|LP|LS)-/, '\1') # should file together regardless of dash

      # normalize number to 7-digits, ignore oversize q
      norm.gsub(/(\d+)(Q?)$/) { format('%07d', Regexp.last_match[1].to_i) }
    end
  end
end
