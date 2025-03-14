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
        'aat_genre_facet'
      when 'Homosaurus genres'
        'homoit_genre_facet'
      when 'Homosaurus terms'
        'homoit_subject_facet'
      when 'Library of Congress genre/form terms for library and archival materials'
        'lcgft_genre_facet'
      when 'Locally assigned term'
        'local_subject_facet'
      when 'Rare books genre term'
        'rbgenr_genre_facet'
      when 'Chinese traditional subjects'
        'siku_subject_facet'
      else
        'lc_subject_facet'
      end
    end
  end
end
