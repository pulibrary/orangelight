module StringFunctions
  class << self
    def cn_normalize(str)
      if /^CD \d+$/ =~ str # the normalizer thinks "CD 104" is valid LC
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
      norm = norm.gsub('CD-', 'CD') # cds should file together regardless of dash
      norm.gsub(/(\d+)$/) { |c| format('%07d', c) } # normalize number to 7-digits
    end
  end
end
