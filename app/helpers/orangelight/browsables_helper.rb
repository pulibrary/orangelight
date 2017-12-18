module Orangelight
  module BrowsablesHelper
    def recap_id?(bib_id)
      /^SCSB-\d+/ =~ bib_id
    end

    def bib_for_availability(bib_id)
      bib_id.to_i.to_s
    end

    def valid_bib_id?(bib_id)
      bib_for_availability(bib_id) == bib_id
    end

    def should_check_availability?(bib_id)
      !recap_id?(bib_id) && valid_bib_id?(bib_id) && render_availability?
    end
  end
end
