# frozen_string_literal: true

module Orangelight
  module BrowsablesHelper
    def scsb_id?(bib_id)
      /^SCSB-\d+/ =~ bib_id
    end

    def bib_for_availability(bib_id)
      bib_id.to_i.to_s
    end

    def valid_bib_id?(bib_id)
      bib_for_availability(bib_id) == bib_id
    end

    def should_check_availability?(bib_id)
      !scsb_id?(bib_id) && valid_bib_id?(bib_id) && render_availability?
    end

    def vocab_type(vocab)
      if vocab == 'Library of Congress genre/form term'
        'lcgft_s'
      elsif vocab == 'Rare books genre term'
        'rbgenr_s'
      else
        'subject_facet'
      end
    end
  end
end
