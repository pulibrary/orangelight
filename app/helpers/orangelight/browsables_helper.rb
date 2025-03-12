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

    def current_browse_per_page
      params[:rpp].present? ? params[:rpp].to_i : 10
    end

    def vocab_type(vocab)
      case vocab
      when 'Art & architecture thesaurus'
        'aat_s'
      when 'Homosaurus: an international LGBTQ linked data vocabulary'
        'homoit_subject_display' || 'homoit_genre_s'
      when 'Library of Congress genre/form terms for library and archival materials'
        'lcgft_s'
      when 'Locally assigned term'
        'local_subject_display'
      when 'Rare books genre term'
        'rbgenr_s'
      else
        # use new field subject_lc
        'lc_subject_facet'
      end
    end
  end
end
