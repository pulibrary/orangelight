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
      vocab_types = {
        'Library of Congress subject heading' => 'lc_subject_facet',
        'Library of Congress genre/form terms for library and archival materials' => 'lcgft_genre_facet',
        'Art & architecture thesaurus' => 'aat_genre_facet',
        'Homosaurus terms' => 'homoit_subject_facet',
        'Homosaurus genres' => 'homoit_genre_facet',
        'Rare books genre term' => 'rbgenr_genre_facet',
        'Chinese traditional subjects' => 'siku_subject_facet',
        'Locally assigned term' => 'local_subject_facet',
      }
      return vocab_types.fetch(vocab, 'subject_facet')
    end
  end
end
