module StringFunctions
  class << self
    def cn_normalize(str)
      Lcsort.normalize(str) || str.upcase
    end

    def oclc_normalize(oclc, _opts = { prefix: false })
      oclc.gsub(/\D/, '').to_i.to_s
    end
  end
end
