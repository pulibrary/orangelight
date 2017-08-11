module Orangelight
  module BrowsablesHelper
    def should_check_availability?(bib_id)
      if /^SCSB-\d+/ =~ bib_id
        false
      else
        bib_for_availability(bib_id) == bib_id
      end
    end

    def bib_for_availability(bib_id)
      bib_id.to_i.to_s
    end
  end
end
