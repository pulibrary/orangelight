# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController
  include Blacklight::Marc::Catalog
  include Blacklight::Catalog
  include BlacklightHelper
  #include BlacklightAdvancedSearch::ParseBasicQ  # adds AND/OR/NOT search term functionality


  def oclc
    redirect_to oclc_resolve(params[:id])
  end

  def isbn
    redirect_to isbn_resolve(params[:id])
  end

  def issn
    redirect_to issn_resolve(params[:id])
  end

  def lccn
    redirect_to lccn_resolve(params[:id])
  end


  self.search_params_logic += [:cjk_mm, :only_home_facets, :left_anchor_strip, :redirect_browse, :tile_sort_starts_with]

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params


    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]
    config.default_per_page = 20

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #

    # config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #   :q => query
    # }


    #new way of calling local document presenter
    config.document_presenter_class = PrincetonPresenter

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.partials = [:index_header, :show_identifiers, :thumbnail, :index]
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.partials = [:show_identifiers, :show]
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'location', :label => 'Library', :limit => 20, sort: 'index',
        home: true, solr_params: { 'facet.mincount' => Blacklight.blacklight_yml['mincount'] || 1 }
    config.add_facet_field 'format', :label => 'Format', partial: "facet_format", sort: 'index',
        :limit => 15, collapse: false, home: true, solr_params: { 'facet.mincount' => Blacklight.blacklight_yml['mincount'] || 1 }

    # num_segments and segments set to defaults here, included to show customizable features
    config.add_facet_field 'pub_date_start_sort', :label => 'Publication Year', :single => true, :range => {
      :num_segments => 10,
      :assumed_boundaries => [1100, Time.now.year+1],
      :segments => true
    }
    config.add_facet_field 'subject_topic_facet', :label => 'Subject: Topic', :limit => true
    config.add_facet_field 'genre_facet', :label => 'Subject: Genre', :limit => true
    config.add_facet_field 'subject_era_facet', :label => 'Subject: Era', :limit => true
    config.add_facet_field 'language_facet', :label => 'Language', :limit => true
    config.add_facet_field 'lc_1letter_facet', :label => 'Classification', :limit => 25, show: false, sort: 'index'
    config.add_facet_field 'author_s', :label => 'Author', :limit => true, show: false
    config.add_facet_field 'lc_rest_facet', :label => 'Full call number code', :limit => 25, show: false, sort: 'index'
    config.add_facet_field 'recently_added_facet', :label => 'Recently Added', home: true, :query => {
       :weeks_1 => { :label => 'Within 1 Week', :fq => "cataloged_tdt:[NOW/DAY-7DAYS NOW/DAY+1DAY]" },
       :months_1 => { :label => 'Within 1 Month', :fq => "cataloged_tdt:[NOW/DAY-1MONTH NOW/DAY+1DAY]" },
       :months_6 => { :label => 'Within 6 Months', :fq => "cataloged_tdt:[NOW/DAY-6MONTHS NOW/DAY+1DAY]" }
    }

    config.add_facet_field 'instrumentation_facet', :label => 'Instrumentation', :limit => true
    config.add_facet_field 'call_number_browse_s', label: 'Call number', show: false

    config.add_facet_field 'call_number_scheme_facet', :label => 'Call number scheme', :limit => 25, show: false, sort: 'index'
    config.add_facet_field 'call_number_group_facet', :label => 'Call number group', :limit => 25, show: false, sort: 'index'
    config.add_facet_field 'call_number_full_facet', :label => 'Full call number', :limit => 25, show: false, sort: 'index'

    config.add_facet_field 'classification_pivot_field', :label => 'Classification', :pivot => ['lc_1letter_facet', 'lc_rest_facet']
    config.add_facet_field 'sudoc_facet', :label => 'SuDocs', :limit => true, sort: 'index'
    config.add_facet_field 'location_code_s', :label => 'Location Code', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_display', :label => 'Author', :helper_method => :browse_name
    config.add_index_field 'pub_created_display', :label => 'Published/Created'
    config.add_index_field 'format', :label => 'Format', helper_method: :format_icon
    config.add_index_field 'holdings_1display', :label => 'Holding info', helper_method: :holding_block_search

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # config.add_show_field 'title_display', :label => 'Title'
    # config.add_show_field 'title_vern_display', :label => 'Title'
    # config.add_show_field 'subtitle_display', :label => 'Subtitle'
    # config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'


    config.add_show_field 'author_display', :label => 'Author', :helper_method => :browse_name
    config.add_show_field 'format', :label => 'Formats'
    config.add_show_field 'url_fulltext_display', :label => 'URL'
    config.add_show_field 'url_suppl_display', :label => 'More Information'
    config.add_show_field 'language_facet', :label => 'Language'
    config.add_show_field 'published_display', :label => 'Published'
    config.add_show_field 'published_vern_display', :label => 'Published'
    config.add_show_field 'pub_created_display', :label => 'Published/Created'


    config.add_show_field 'uniform_title_display', :label => 'Uniform Title'
    config.add_show_field 'compiled_created_display', :label => 'Compiled/Created'
    config.add_show_field 'edition_display', :label => 'Εdition'
    config.add_show_field 'medium_support_display', :label => 'Medium/Support'
    # This is now routed to the sidebar
    #config.add_show_field 'electronic_access_1display', :label => 'Electronic access', :helper_method => :urlify

    config.add_show_field 'description_display', :label => 'Description'
    config.add_show_field 'arrangement_display', :label => 'Arrangement'
    config.add_show_field 'translation_of_display', :label => 'Translation of'
    config.add_show_field 'translated_as_display', :label => 'Translated as'
    config.add_show_field 'issued_with_display', :label => 'Issued with'
    config.add_show_field 'continues_display', :label => 'Continues'
    config.add_show_field 'continues_in_part_display', :label => 'Continues in part'
    config.add_show_field 'formed_from_display', :label => 'Formed from'
    config.add_show_field 'absorbed_display', :label => 'Absorbed'
    config.add_show_field 'absorbed_in_part_display', :label => 'Absorbed in part'
    config.add_show_field 'separated_from_display', :label => 'Separated from'
    config.add_show_field 'continued_by_display', :label => 'Continued by'
    config.add_show_field 'continued_in_part_by_display', :label => 'Continued in part by'
    config.add_show_field 'absorbed_by_display', :label => 'Absorbed by'
    config.add_show_field 'absorbed_in_part_by_display', :label => 'Absorbed in part by'
    config.add_show_field 'split_into_display', :label => 'Split into'
    config.add_show_field 'merged_to_form_display', :label => 'Merged to form'
    config.add_show_field 'changed_back_to_display', :label => 'Changed back to'
    config.add_show_field 'frequency_display', :label => 'Frequency'
    config.add_show_field 'former_frequency_display', :label => 'Former frequency'
    config.add_show_field 'has_supplement_display', :label => 'Has supplement'
    config.add_show_field 'supplement_to_display', :label => 'Supplement to'
    config.add_show_field 'linking_notes_display', :label => 'Linking notes'
    config.add_show_field 'subseries_of_display', :label => 'Subseries of'
    config.add_show_field 'has_subseries_display', :label => 'Has subseries'
    config.add_show_field 'series_display', :label => 'Series'
    config.add_show_field 'restrictions_note_display', :label => 'Restrictions note'
    config.add_show_field 'biographical_historical_note_display', :label => 'Biographical/Historical note'
    config.add_show_field 'summary_note_display', :label => 'Summary note'
    config.add_show_field 'notes_display', :label => 'Notes'

    config.add_show_field 'with_notes_display', :label => 'With'
    config.add_show_field 'bibliographic_notes_display', :label => 'Bibliographic history'
    config.add_show_field 'dissertation_notes_display', :label => 'Dissertation note'
    config.add_show_field 'bib_ref_notes_display', :label => 'Bibliographic references'
    config.add_show_field 'scale_notes_display', :label => 'Scale'
    config.add_show_field 'credits_notes_display', :label => 'Creation/Production credits'
    config.add_show_field 'type_period_notes_display', :label => 'Type of report and period covered'
    config.add_show_field 'data_quality_notes_display', :label => 'Data quality'
    config.add_show_field 'numbering_pec_notes_display', :label => 'Numbering peculiarities'
    config.add_show_field 'type_comp_data_notes_display', :label => 'Type of data'
    config.add_show_field 'date_place_event_notes_display', :label => 'Time and place of event'
    config.add_show_field 'target_aud_notes_display', :label => 'Target audience'
    config.add_show_field 'geo_cov_notes_display', :label => 'Geographic coverage'
    config.add_show_field 'time_period_notes_display', :label => 'Time period of content'
    config.add_show_field 'supplement_notes_display', :label => 'Supplement note'
    config.add_show_field 'study_prog_notes_display', :label => 'Study program information'
    config.add_show_field 'censorship_notes_display', :label => 'Censorship note'
    config.add_show_field 'reproduction_notes_display', :label => 'Reproduction note'
    config.add_show_field 'original_version_notes_display', :label => 'Original version'
    config.add_show_field 'location_originals_notes_display', :label => 'Location of originals'
    config.add_show_field 'funding_info_notes_display', :label => 'Funding information'
    config.add_show_field 'source_data_notes_display', :label => 'Source of data'
    config.add_show_field 'system_details_notes_display', :label => 'System details'
    config.add_show_field 'related_copyright_notes_display', :label => 'Copyright note'
    config.add_show_field 'location_other_arch_notes_display', :label => 'Location of other archival materials'
    config.add_show_field 'former_title_complex_notes_display', :label => 'Former title complexity'
    config.add_show_field 'issuing_body_notes_display', :label => 'Issuing body'
    config.add_show_field 'info_document_notes_display', :label => 'Information about documentation'
    config.add_show_field 'copy_version_notes_display', :label => 'Copy and version identification'
    config.add_show_field 'case_file_notes_display', :label => 'Case file characteristics'
    config.add_show_field 'methodology_notes_display', :label => 'Methodology note'
    config.add_show_field 'editor_notes_display', :label => 'Editor note'
    config.add_show_field 'action_notes_display', :label => 'Action note'
    config.add_show_field 'accumulation_notes_display', :label => 'Accumulation and frequency of use'
    config.add_show_field 'awards_notes_display', :label => 'Awards'
    config.add_show_field 'source_desc_notes_display', :label => 'Source of description'

    config.add_show_field 'binding_note_display', :label => 'Binding note'
    config.add_show_field 'local_notes_display', :label => 'Local notes'
    config.add_show_field 'rights_reproductions_note_display', :label => 'Rights and reproductions note'
    config.add_show_field 'exhibitions_note_display', :label => 'Exhibitions note'
    config.add_show_field 'participant_performer_display', :label => 'Participant(s)/&#8203;Performer(s)'
    config.add_show_field 'language_display', :label => 'Language(s)'
    config.add_show_field 'script_display', :label => 'Script'
    config.add_show_field 'contents_display', :label => 'Contents'
    config.add_show_field 'incomplete_contents_display', :label => 'Incomplete contents'
    config.add_show_field 'partial_contents_display', :label => 'Partial contents'
    config.add_show_field 'provenance_display', :label => 'Provenance'
    config.add_show_field 'source_acquisition_display', :label => 'Source acquisition'
    config.add_show_field 'publications_about_display', :label => 'Publications about'
    config.add_show_field 'indexed_in_display', :label => 'Indexed in'
    config.add_show_field 'references_display', :label => 'References'
    config.add_show_field 'cite_as_display', :label => 'Cite as'
    config.add_show_field 'other_format_display', :label => 'Other format(s)'
    config.add_show_field 'cumulative_index_finding_aid_display', :label => 'Cumulative index finding aid'
    config.add_show_field 'subject_display', :label => 'Subject(s)', helper_method: :subjectify
    config.add_show_field 'form_genre_display', :label => 'Form genre'
    config.add_show_field 'related_works_display', :label => 'Related work(s)'
    config.add_show_field 'contains_display', :label => 'Contains'
    config.add_show_field 'place_name_display', :label => 'Place name(s)'
    config.add_show_field 'other_title_display', :label => 'Other title(s)'
    config.add_show_field 'in_display', :label => 'In'
    config.add_show_field 'constituent_part_display', :label => 'Constituent part(s)'
    config.add_show_field 'isbn_display', :label => 'ISBN'
    config.add_show_field 'issn_display', :label => 'ISSN'
    config.add_show_field 'sudoc_no_display', :label => 'SuDoc no.'
    config.add_show_field 'tech_report_no_display', :label => 'Tech. report no.'
    config.add_show_field 'publisher_no_display', :label => 'Publisher no.'
    config.add_show_field 'lccn_display', :label => 'LCCN'
    config.add_show_field 'oclc_s', :label => 'OCLC'
    config.add_show_field 'other_version_s', :label => 'Other versions'
    config.add_show_field 'coden_display', :label => 'Coden designation'
    config.add_show_field 'standard_no_1display', hash: true
    config.add_show_field 'original_language_display', :label => 'Original language'
    config.add_show_field 'shelving_title_display', :label => 'Shelving title'
    config.add_show_field 'location_has_display', :label => 'Location has'
    config.add_show_field 'location_has_current_display', :label => 'Location has (current)'
    config.add_show_field 'supplements_display', :label => 'Supplements'
    config.add_show_field 'indexes_display', :label => 'Indexes'
    config.add_show_field 'location_notes_display', :label => 'Location notes'
    config.add_show_field 'related_name_json_1display', hash: true
# # 'Other version(s)_display'
# # 'Contained in_display'
# # 'Related record(s)_display'
# # 'Holdings information_display'
# # 'Item details_display'
# # 'Order information_display'
# # 'E-items_display'
# # 'Status_display'
# # 'Linked resources_display'



#     "fielded" search configuration. Used by pulldown among other places.
#     For supported keys in hash, see rdoc for Blacklight::SearchFields

#     Search fields will inherit the :qt solr request handler from
#     config[:default_solr_parameters], OR can specify a different one
#     with a :qt key/value. Below examples inherit, except for subject
#     that specifies the same :qt as default for our own internal
#     testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # To add an advanced option only search field:
    #   config.add_search_field("advanced_field") do |field|
    #   field.include_in_simple_select = false
    #   field.solr_parameters = { :qf => "advanced_field_solrname" }
    # end
    # if the request handler ends up being different for advanced fields, they must be
    # specifically included, while at the same time be removed from simple search:
    #   :include_in_advanced_search => true
    #   field.include_in_simple_select = false

    config.add_search_field 'all_fields', :label => 'All Fields' do |field|
    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }
      field.dropdown_label = "Title (keyword)"

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.dropdown_label = "Author (keyword)"
      field.solr_local_parameters = {
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.dropdown_label = "Subject (keyword)"
      field.qt = 'search'
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    config.add_search_field('left_anchor') do |field|
      field.label = 'Title starts with'
      field.solr_local_parameters = {
        :qf => '$left_anchor_qf',
        :pf => '$left_anchor_pf'
      }
    end

    config.add_search_field('browse_subject') do |field|
      field.include_in_advanced_search = false
      field.label = 'Subject (browse)'
    end
    config.add_search_field('browse_name') do |field|
      field.include_in_advanced_search = false
      field.label = 'Author (browse)'
    end
    config.add_search_field('browse_cn') do |field|
      field.include_in_advanced_search = false
      field.label = 'Call number (browse)'
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_start_sort desc, title_sort asc', :label => 'Relevance'
    config.add_sort_field 'pub_date_start_sort desc, title_sort asc', :label => 'Year (newest first)'
    config.add_sort_field 'pub_date_start_sort asc, title_sort asc', :label => 'Year (oldest first)'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'Author'
    config.add_sort_field 'title_sort asc, pub_date_start_sort desc', :label => 'Title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Add bookmark all widget
    config.add_results_collection_tool(:bookmark_all)
  end

end
