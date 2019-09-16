# frozen_string_literal: false

class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include Blacklight::Catalog
  include BlacklightUnapi::ControllerExtension

  # include Blacklight::Marc::Catalog
  include BlacklightRangeLimit::ControllerOverride
  include Orangelight::Catalog
  include Orangelight::Stackmap
  include BlacklightHelper

  before_action :redirect_browse

  rescue_from Blacklight::Exceptions::RecordNotFound do
    redirect_to '/404'
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to solr_document_path(params[:id])
  end

  rescue_from BlacklightRangeLimit::InvalidRange do
    redirect_to '/', flash: { error: 'The start year must be before the end year.' }
  end

  configure_blacklight do |config|
    config.raw_endpoint.enabled = true

    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {}
    config.advanced_search[:form_solr_parameters]['facet.field'] ||= %w[access_facet format language_facet advanced_location_s]
    config.advanced_search[:form_solr_parameters]['facet.query'] ||= ''
    config.advanced_search[:form_solr_parameters]['facet.limit'] ||= -1
    config.advanced_search[:form_solr_parameters]['facet.pivot'] ||= ''
    config.advanced_search[:form_solr_parameters]['f.language_facet.facet.limit'] ||= -1
    config.advanced_search[:form_solr_parameters]['f.language_facet.facet.sort'] ||= 'index'

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]
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

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.navbar.partials.delete(:search_history)
    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark')
    config.add_nav_action(:reserves, partial: 'course_reserves/nav')

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.partials = %i[index_header show_identifiers thumbnail index]
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.partials = %i[show_identifiers show]
    # config.show.title_field = 'title_display'
    # config.show.display_type_field = 'format'

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
    config.add_facet_field 'access_facet', label: 'Access', sort: 'index', collapse: false, home: true
    config.add_facet_field 'location', label: 'Library', limit: 20, sort: 'index',
                                       home: true, solr_params: { 'facet.mincount' => Blacklight.blacklight_yml['mincount'] || 1 }
    config.add_facet_field 'format', label: 'Format', partial: 'facet_format', sort: 'index', limit: 15,
                                     collapse: false, home: true, solr_params: { 'facet.mincount' => Blacklight.blacklight_yml['mincount'] || 1 }

    # num_segments and segments set to defaults here, included to show customizable features
    config.add_facet_field 'pub_date_start_sort', label: 'Publication year', single: true, range: {
      num_segments: 10,
      assumed_boundaries: [1100, Time.now.year + 1],
      segments: true
    }
    config.add_facet_field 'language_facet', label: 'Language', limit: true
    config.add_facet_field 'subject_topic_facet', label: 'Subject: Topic', limit: true
    config.add_facet_field 'genre_facet', label: 'Subject: Genre', limit: true
    config.add_facet_field 'subject_era_facet', label: 'Subject: Era', limit: true
    config.add_facet_field 'lc_1letter_facet', label: 'Classification', limit: 25, show: false, sort: 'index'
    config.add_facet_field 'author_s', label: 'Author', limit: true, show: false
    config.add_facet_field 'class_year_s', label: 'PU class year', limit: true, show: false
    config.add_facet_field 'lc_rest_facet', label: 'Full call number code', limit: 25, show: false, sort: 'index'
    config.add_facet_field 'recently_added_facet', label: 'Recently added', home: true, query: {
      weeks_1: { label: 'Within 1 week', fq: 'cataloged_tdt:[NOW/DAY-7DAYS TO NOW/DAY+1DAY]' },
      weeks_2: { label: 'Within 2 weeks', fq: 'cataloged_tdt:[NOW/DAY-14DAYS TO NOW/DAY+1DAY]' },
      weeks_3: { label: 'Within 3 weeks', fq: 'cataloged_tdt:[NOW/DAY-21DAYS TO NOW/DAY+1DAY]' },
      months_1: { label: 'Within 1 month', fq: 'cataloged_tdt:[NOW/DAY-1MONTH TO NOW/DAY+1DAY]' },
      months_2: { label: 'Within 2 months', fq: 'cataloged_tdt:[NOW/DAY-2MONTHS TO NOW/DAY+1DAY]' },
      months_3: { label: 'Within 3 months', fq: 'cataloged_tdt:[NOW/DAY-3MONTHS TO NOW/DAY+1DAY]' },
      months_6: { label: 'Within 6 months', fq: 'cataloged_tdt:[NOW/DAY-6MONTHS TO NOW/DAY+1DAY]' }
    }

    config.add_facet_field 'instrumentation_facet', label: 'Instrumentation', limit: true
    config.add_facet_field 'call_number_browse_s', label: 'Call number', show: false

    config.add_facet_field 'call_number_scheme_facet', label: 'Call number scheme', limit: 25, show: false, sort: 'index'
    config.add_facet_field 'call_number_group_facet', label: 'Call number group', limit: 25, show: false, sort: 'index'
    config.add_facet_field 'call_number_full_facet', label: 'Full call number', limit: 25, show: false, sort: 'index'
    config.add_facet_field 'publication_place_facet', label: 'Place of publication', limit: true
    config.add_facet_field 'classification_pivot_field', label: 'Classification', pivot: %w[lc_1letter_facet lc_rest_facet]
    config.add_facet_field 'sudoc_facet', label: 'SuDocs', limit: true, sort: 'index'
    config.add_facet_field 'advanced_location_s', label: 'Holding location', show: false,
                                                  helper_method: :render_location_code
    config.add_facet_field 'name_title_browse_s', label: 'Author-title heading', show: false

    # Numismatics facets
    config.add_facet_field 'issue_number_s', label: 'Issue', show: false
    config.add_facet_field 'issue_monogram_title_s', label: 'Monogram', show: false
    config.add_facet_field 'issue_references_s', label: 'References', show: false
    config.add_facet_field 'accession_info_s', label: 'Accession info', show: false
    config.add_facet_field 'analysis_s', label: 'Analysis', show: false
    config.add_facet_field 'counter_stamp_s', label: 'Counter Stamp', show: false
    config.add_facet_field 'die_axis_s', label: 'Die Axis', show: false
    config.add_facet_field 'find_date_s', label: 'Find Date', show: false
    config.add_facet_field 'find_description_s', label: 'Find Description', show: false
    config.add_facet_field 'find_feature_s', label: 'Find Feature', show: false
    config.add_facet_field 'find_locus_s', label: 'Find Locus', show: false
    config.add_facet_field 'find_number_s', label: 'Find Number', show: false
    config.add_facet_field 'find_place_s', label: 'Find Place', show: false
    config.add_facet_field 'issue_color_s', label: 'Color', show: false
    config.add_facet_field 'issue_denomination_s', label: 'Denomination', show: false
    config.add_facet_field 'issue_edge_s', label: 'Edge', show: false
    config.add_facet_field 'issue_era_s', label: 'Era', show: false
    config.add_facet_field 'issue_master_s', label: 'Master', show: false
    config.add_facet_field 'issue_metal_s', label: 'Metal', show: false
    config.add_facet_field 'issue_place_s', label: 'Place', show: false
    config.add_facet_field 'issue_object_type_s', label: 'Object Type', show: false
    config.add_facet_field 'issue_obverse_attributes_s', label: 'Obverse Attributes', show: false
    config.add_facet_field 'issue_obverse_figure_description_s', label: 'Obverse Figure Description', show: false
    config.add_facet_field 'issue_obverse_figure_relationship_s', label: 'Obverse Figure Relationship', show: false
    config.add_facet_field 'issue_obverse_figure_s', label: 'Obverse Figure', show: false
    config.add_facet_field 'issue_obverse_legend_s', label: 'Obverse Legend', show: false
    config.add_facet_field 'issue_obverse_orientation_s', label: 'Obverse Orientation', show: false
    config.add_facet_field 'issue_obverse_part_s', label: 'Obverse Part', show: false
    config.add_facet_field 'issue_obverse_symbol_s', label: 'Obverse Symbol', show: false
    config.add_facet_field 'issue_reverse_attributes_s', label: 'Reverse Attributes', show: false
    config.add_facet_field 'issue_reverse_figure_description_s', label: 'Reverse Figure Description', show: false
    config.add_facet_field 'issue_reverse_figure_relationship_s', label: 'Reverse Figure Relationship', show: false
    config.add_facet_field 'issue_reverse_figure_s', label: 'Reverse Figure', show: false
    config.add_facet_field 'issue_reverse_legend_s', label: 'Reverse Legend', show: false
    config.add_facet_field 'issue_reverse_orientation_s', label: 'Reverse Orientation', show: false
    config.add_facet_field 'issue_reverse_part_s', label: 'Reverse Part', show: false
    config.add_facet_field 'issue_reverse_symbol_s', label: 'Reverse Symbol', show: false
    config.add_facet_field 'issue_ruler_s', label: 'Ruler', show: false
    config.add_facet_field 'issue_series_s', label: 'Series', show: false
    config.add_facet_field 'issue_shape_s', label: 'Shape', show: false
    config.add_facet_field 'issue_workshop_s', label: 'Workshop', show: false
    config.add_facet_field 'size_s', label: 'Size', show: false
    config.add_facet_field 'technique_s', label: 'Technique', show: false
    config.add_facet_field 'weight_s', label: 'Weight', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'series_display', label: 'Series', helper_method: :series_results
    config.add_index_field 'author_display', label: 'Author/Artist', helper_method: :browse_name
    config.add_index_field 'pub_created_display', label: 'Published/Created'
    config.add_index_field 'format', label: 'Format', helper_method: :format_icon
    config.add_index_field 'holdings_1display', show: false
    config.add_index_field 'isbn_t', show: false
    config.add_index_field 'score', show: false
    config.add_index_field 'marc_relator_display', show: false
    config.add_index_field 'title_display', show: false
    config.add_index_field 'title_vern_display', show: false
    config.add_index_field 'isbn_s', show: false
    config.add_index_field 'oclc_s', show: false
    config.add_index_field 'lccn_s', show: false
    config.add_index_field 'electronic_access_1display', show: false
    config.add_index_field 'cataloged_tdt', show: false

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # config.add_show_field 'title_display', :label => 'Title'
    # config.add_show_field 'title_vern_display', :label => 'Title'
    # config.add_show_field 'subtitle_display', :label => 'Subtitle'
    # config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'

    # Top fields in show page / prioritized information
    config.add_show_field 'author_display', label: 'Author/&#8203;Artist', helper_method: :browse_name, if: false
    config.add_show_field 'name_uniform_title_1display', label: 'Uniform title', helper_method: :name_title_hierarchy, if: false
    config.add_show_field 'format', label: 'Format', helper_method: :format_render, if: false
    config.add_show_field 'language_facet', label: 'Language', if: false
    config.add_show_field 'edition_display', label: 'Εdition', if: false
    config.add_show_field 'pub_created_display', label: 'Published/&#8203;Created', if: false
    config.add_show_field 'description_display', label: 'Description', if: false

    # Senior Thesis linked fields
    config.add_show_field 'advisor_display', label: 'Advisor(s)', helper_method: :browse_name
    config.add_show_field 'contributor_display', label: 'Contributor(s)', helper_method: :browse_name
    config.add_show_field 'department_display', label: 'Department', helper_method: :browse_name
    config.add_show_field 'certificate_display', label: 'Certificate', helper_method: :browse_name

    config.add_show_field 'class_year_s', label: 'Class year', helper_method: :link_to_search_value
    # Linked fields pushed to top of supplemental info
    config.add_show_field 'subject_display', label: 'Subject(s)', helper_method: :subjectify
    config.add_show_field 'related_name_json_1display', hash: true
    config.add_show_field 'form_genre_display', label: 'Form/&#8203;Genre'
    config.add_show_field 'related_works_1display', label: 'Related work(s)', helper_method: :name_title_hierarchy
    config.add_show_field 'series_display', label: 'Series', helper_method: :series_with_links
    config.add_show_field 'contains_1display', label: 'Contains', helper_method: :name_title_hierarchy
    config.add_show_field 'data_source_display', label: 'Data source', helper_method: :name_title
    config.add_show_field 'contained_in_s', label: 'Contained in', link_field: 'id'
    config.add_show_field 'related_record_s', label: 'Related record(s)', link_field: 'id'
    config.add_show_field 'translation_of_display', label: 'Translation of', helper_method: :name_title
    config.add_show_field 'translated_as_display', label: 'Translated as', helper_method: :name_title
    config.add_show_field 'issued_with_display', label: 'Issued with', helper_method: :name_title
    config.add_show_field 'continues_display', label: 'Continues', helper_method: :name_title
    config.add_show_field 'continues_in_part_display', label: 'Continues in part', helper_method: :name_title
    config.add_show_field 'formed_from_display', label: 'Formed from', helper_method: :name_title
    config.add_show_field 'absorbed_display', label: 'Absorbed', helper_method: :name_title
    config.add_show_field 'absorbed_in_part_display', label: 'Absorbed in part', helper_method: :name_title
    config.add_show_field 'separated_from_display', label: 'Separated from', helper_method: :name_title
    config.add_show_field 'continued_by_display', label: 'Continued by', helper_method: :name_title
    config.add_show_field 'continued_in_part_by_display', label: 'Continued in part by', helper_method: :name_title
    config.add_show_field 'absorbed_by_display', label: 'Absorbed by', helper_method: :name_title
    config.add_show_field 'absorbed_in_part_by_display', label: 'Absorbed in part by', helper_method: :name_title
    config.add_show_field 'split_into_display', label: 'Split into', helper_method: :name_title
    config.add_show_field 'merged_to_form_display', label: 'Merged to form', helper_method: :name_title
    config.add_show_field 'changed_back_to_display', label: 'Changed back to', helper_method: :name_title
    config.add_show_field 'subseries_of_display', label: 'Subseries of', helper_method: :name_title
    config.add_show_field 'has_subseries_display', label: 'Has subseries', helper_method: :name_title
    config.add_show_field 'has_supplement_display', label: 'Has supplement', helper_method: :name_title
    config.add_show_field 'supplement_to_display', label: 'Supplement to', helper_method: :name_title

    # Fields that are not links
    config.add_show_field 'url_fulltext_display', label: 'URL'
    config.add_show_field 'url_suppl_display', label: 'More information'
    config.add_show_field 'compiled_created_display', label: 'Compiled/&#8203;Created'
    config.add_show_field 'medium_support_display', label: 'Medium/&#8203;Support'
    config.add_show_field 'numbering_pec_notes_display', label: 'Numbering peculiarities'
    config.add_show_field 'arrangement_display', label: 'Arrangement'
    config.add_show_field 'frequency_display', label: 'Frequency'
    config.add_show_field 'former_frequency_display', label: 'Former frequency'
    config.add_show_field 'linking_notes_display', label: 'Linking notes'
    config.add_show_field 'restrictions_note_display', label: 'Restrictions note', helper_method: :html_safe
    config.add_show_field 'biographical_historical_note_display', label: 'Biographical/&#8203;Historical note'
    config.add_show_field 'summary_note_display', label: 'Summary note'
    config.add_show_field 'notes_display', label: 'Notes'
    config.add_show_field 'holdings_1display', label: 'Location has', if: :online_holding_note?, helper_method: :location_has
    config.add_show_field 'with_notes_display', label: 'With'
    config.add_show_field 'bibliographic_notes_display', label: 'Bibliographic history'
    config.add_show_field 'dissertation_notes_display', label: 'Dissertation note'
    config.add_show_field 'bib_ref_notes_display', label: 'Bibliographic references'
    config.add_show_field 'scale_notes_display', label: 'Scale'
    config.add_show_field 'credits_notes_display', label: 'Creation/&#8203;Production credits'
    config.add_show_field 'type_period_notes_display', label: 'Type of report and period covered'
    config.add_show_field 'data_quality_notes_display', label: 'Data quality'
    config.add_show_field 'type_comp_data_notes_display', label: 'Type of data'
    config.add_show_field 'date_place_event_notes_display', label: 'Time and place of event'
    config.add_show_field 'target_aud_notes_display', label: 'Target audience'
    config.add_show_field 'geo_cov_notes_display', label: 'Geographic coverage'
    config.add_show_field 'time_period_notes_display', label: 'Time period of content'
    config.add_show_field 'supplement_notes_display', label: 'Supplement note'
    config.add_show_field 'study_prog_notes_display', label: 'Study program information'
    config.add_show_field 'censorship_notes_display', label: 'Censorship note'
    config.add_show_field 'reproduction_notes_display', label: 'Reproduction note'
    config.add_show_field 'original_version_notes_display', label: 'Original version'
    config.add_show_field 'location_originals_notes_display', label: 'Location of originals'
    config.add_show_field 'funding_info_notes_display', label: 'Funding information'
    config.add_show_field 'source_data_notes_display', label: 'Source of data'
    config.add_show_field 'system_details_notes_display', label: 'System details'
    config.add_show_field 'related_copyright_notes_display', label: 'Copyright note'
    config.add_show_field 'location_other_arch_notes_display', label: 'Location of other archival materials'
    config.add_show_field 'former_title_complex_notes_display', label: 'Former title complexity'
    config.add_show_field 'issuing_body_notes_display', label: 'Issuing body'
    config.add_show_field 'info_document_notes_display', label: 'Information about documentation'
    config.add_show_field 'copy_version_notes_display', label: 'Copy and version identification'
    config.add_show_field 'case_file_notes_display', label: 'Case file characteristics'
    config.add_show_field 'methodology_notes_display', label: 'Methodology note'
    config.add_show_field 'editor_notes_display', label: 'Editor note'
    config.add_show_field 'action_notes_display', label: 'Action note'
    config.add_show_field 'accumulation_notes_display', label: 'Accumulation and frequency of use'
    config.add_show_field 'awards_notes_display', label: 'Awards'
    config.add_show_field 'source_desc_notes_display', label: 'Source of description'
    config.add_show_field 'binding_note_display', label: 'Binding note'
    config.add_show_field 'local_notes_display', label: 'Local notes'
    config.add_show_field 'rights_reproductions_note_display', label: 'Rights and reproductions note', helper_method: :html_safe
    config.add_show_field 'exhibitions_note_display', label: 'Exhibitions note'
    config.add_show_field 'participant_performer_display', label: 'Participant(s)/&#8203;Performer(s)'
    config.add_show_field 'language_display', label: 'Language(s)'
    config.add_show_field 'script_display', label: 'Script'
    config.add_show_field 'contents_display', label: 'Contents'
    config.add_show_field 'incomplete_contents_display', label: 'Incomplete contents'
    config.add_show_field 'partial_contents_display', label: 'Partial contents'
    config.add_show_field 'provenance_display', label: 'Provenance'
    config.add_show_field 'source_acquisition_display', label: 'Source acquisition'
    config.add_show_field 'publications_about_display', label: 'Publications about'
    config.add_show_field 'indexed_in_display', label: 'Indexed in'
    config.add_show_field 'references_url_display', label: 'References', helper_method: :references_url
    config.add_show_field 'cite_as_display', label: 'Cite as'
    config.add_show_field 'other_format_display', label: 'Other format(s)'
    config.add_show_field 'indexes_display', label: 'Indexes'
    config.add_show_field 'finding_aid_display', label: 'Finding aid'
    config.add_show_field 'cumulative_index_finding_aid_display', label: 'Cumulative index/&#8203;Finding aid'
    config.add_show_field 'place_name_display', label: 'Place name(s)'
    config.add_show_field 'other_title_display', label: 'Other title(s)'
    config.add_show_field 'other_title_1display', hash: true
    config.add_show_field 'in_display', label: 'In'
    config.add_show_field 'constituent_part_display', label: 'Constituent part(s)'
    config.add_show_field 'other_editions_display', label: 'Other editions'
    config.add_show_field 'isbn_display', label: 'ISBN'
    config.add_show_field 'issn_display', label: 'ISSN'
    config.add_show_field 'sudoc_no_display', label: 'SuDoc no.'
    config.add_show_field 'tech_report_no_display', label: 'Tech. report no.'
    config.add_show_field 'publisher_no_display', label: 'Publisher no.'
    config.add_show_field 'lccn_display', label: 'LCCN'
    config.add_show_field 'oclc_s', label: 'OCLC'
    config.add_show_field 'coden_display', label: 'Coden designation'
    config.add_show_field 'standard_no_1display', hash: true
    config.add_show_field 'original_language_display', label: 'Original language'
    config.add_show_field 'recap_notes_display', label: 'RCP', helper_method: :recap_note

    # Numismatics fields
    config.add_show_field 'issue_number_s', label: 'Issue', helper_method: :link_to_search_value, if: false
    config.add_show_field 'issue_references_s', label: 'References', helper_method: :link_to_search_value, if: false
    config.add_show_field 'accession_info_s', label: 'Accession info', helper_method: :link_to_search_value
    config.add_show_field 'analysis_s', label: 'Analysis', helper_method: :link_to_search_value
    config.add_show_field 'counter_stamp_s', label: 'Counter Stamp', helper_method: :link_to_search_value
    config.add_show_field 'die_axis_s', label: 'Die Axis', helper_method: :link_to_search_value
    config.add_show_field 'find_date_s', label: 'Find Date', helper_method: :link_to_search_value
    config.add_show_field 'find_description_s', label: 'Find Description', helper_method: :link_to_search_value
    config.add_show_field 'find_feature_s', label: 'Find Feature', helper_method: :link_to_search_value
    config.add_show_field 'find_locus_s', label: 'Find Locus', helper_method: :link_to_search_value
    config.add_show_field 'find_number_s', label: 'Find Number', helper_method: :link_to_search_value
    config.add_show_field 'find_place_s', label: 'Find Place', helper_method: :link_to_search_value
    config.add_show_field 'issue_color_s', label: 'Color', helper_method: :link_to_search_value
    config.add_show_field 'issue_denomination_s', label: 'Denomination', helper_method: :link_to_search_value
    config.add_show_field 'issue_edge_s', label: 'Edge', helper_method: :link_to_search_value
    config.add_show_field 'issue_era_s', label: 'Era', helper_method: :link_to_search_value
    config.add_show_field 'issue_master_s', label: 'Master', helper_method: :link_to_search_value
    config.add_show_field 'issue_metal_s', label: 'Metal', helper_method: :link_to_search_value
    config.add_show_field 'issue_place_s', label: 'Place', helper_method: :link_to_search_value
    config.add_show_field 'issue_object_type_s', label: 'Object Type', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_attributes_s', label: 'Obverse Attributes', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_figure_description_s', label: 'Obverse Figure Description', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_figure_relationship_s', label: 'Obverse Figure Relationship', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_figure_s', label: 'Obverse Figure', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_legend_s', label: 'Obverse Legend', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_orientation_s', label: 'Obverse Orientation', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_part_s', label: 'Obverse Part', helper_method: :link_to_search_value
    config.add_show_field 'issue_obverse_symbol_s', label: 'Obverse Symbol', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_attributes_s', label: 'Reverse Attributes', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_figure_description_s', label: 'Reverse Figure Description', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_figure_relationship_s', label: 'Reverse Figure Relationship', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_figure_s', label: 'Reverse Figure', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_legend_s', label: 'Reverse Legend', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_orientation_s', label: 'Reverse Orientation', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_part_s', label: 'Reverse Part', helper_method: :link_to_search_value
    config.add_show_field 'issue_reverse_symbol_s', label: 'Reverse Symbol', helper_method: :link_to_search_value
    config.add_show_field 'issue_ruler_s', label: 'Ruler', helper_method: :link_to_search_value
    config.add_show_field 'issue_series_s', label: 'Series', helper_method: :link_to_search_value
    config.add_show_field 'issue_shape_s', label: 'Shape', helper_method: :link_to_search_value
    config.add_show_field 'issue_workshop_s', label: 'Workshop', helper_method: :link_to_search_value
    config.add_show_field 'size_s', label: 'Size', helper_method: :link_to_search_value
    config.add_show_field 'technique_s', label: 'Technique', helper_method: :link_to_search_value
    config.add_show_field 'weight_s', label: 'Weight', helper_method: :link_to_search_value

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

    config.add_search_field 'all_fields', label: 'Keyword' do |field|
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
      field.dropdown_label = 'Title (keyword)'
      field.solr_adv_parameters = {
        qf: '$title_qf',
        pf: '$title_pf'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary' => 'author',
        qf: '${author_qf}',
        pf: '${author_pf}'
      }
      field.dropdown_label = 'Author (keyword)'
      field.label = 'Author/Creator'
      field.solr_adv_parameters = {
        qf: '$author_qf',
        pf: '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'subject',
        qf: '${subject_qf}',
        pf: '${subject_pf}'
      }
      field.dropdown_label = 'Subject (keyword)'
      field.qt = 'search'
      field.solr_adv_parameters = {
        qf: '$subject_qf',
        pf: '$subject_pf'
      }
    end

    config.add_search_field('left_anchor') do |field|
      field.label = 'Title starts with'
      field.solr_parameters = {
        qf: '${left_anchor_qf}',
        pf: '${left_anchor_pf}'
      }
      field.solr_adv_parameters = {
        qf: '$left_anchor_qf',
        pf: '$left_anchor_pf'
      }
    end

    config.add_search_field('publisher') do |field|
      field.include_in_simple_select = false
      field.label = 'Publisher'
      field.solr_adv_parameters = {
        qf: '$publisher_qf',
        pf: '$publisher_pf'
      }
    end

    config.add_search_field('in_series') do |field|
      field.include_in_advanced_search = false
      field.include_in_simple_select = false
      field.label = 'Series starts with'
      field.solr_adv_parameters = {
        qf: '$in_series_qf',
        pf: '$in_series_pf'
      }
    end

    config.add_search_field('notes') do |field|
      field.include_in_simple_select = false
      field.label = 'Notes'
      field.solr_adv_parameters = {
        qf: '$notes_qf',
        pf: '$notes_pf'
      }
    end

    config.add_search_field('series_title') do |field|
      field.include_in_simple_select = false
      field.label = 'Series title'
      field.solr_adv_parameters = {
        qf: '$series_title_qf',
        pf: '$series_title_pf'
      }
    end

    config.add_search_field('isbn') do |field|
      field.include_in_simple_select = false
      field.label = 'ISBN'
      field.solr_adv_parameters = {
        qf: 'isbn_t'
      }
      field.solr_parameters = {
        qf: 'isbn_t'
      }
    end

    config.add_search_field('issn') do |field|
      field.include_in_simple_select = false
      field.label = 'ISSN'
      field.solr_adv_parameters = {
        qf: 'issn_s'
      }
      field.solr_parameters = {
        qf: 'issn_s'
      }
    end

    config.add_search_field('lccn') do |field|
      field.include_in_simple_select = false
      field.include_in_advanced_search = false
      field.label = 'LCCN'
      field.solr_adv_parameters = {
        qf: 'lccn_s'
      }
      field.solr_parameters = {
        qf: 'lccn_s'
      }
    end

    config.add_search_field('oclc') do |field|
      field.include_in_simple_select = false
      field.include_in_advanced_search = false
      field.label = 'OCLC'
      field.solr_adv_parameters = {
        qf: 'oclc_s'
      }
      field.solr_adv_parameters = {
        qf: 'oclc_s'
      }
    end

    config.add_search_field('browse_subject') do |field|
      field.include_in_advanced_search = false
      field.label = 'Subject (browse)'
    end
    config.add_search_field('browse_name') do |field|
      field.include_in_advanced_search = false
      field.label = 'Author (browse)'
      field.placeholder_text = 'Last name, first name'
    end
    config.add_search_field('name_title') do |field|
      field.include_in_advanced_search = false
      field.label = 'Author (sorted by title)'
      field.placeholder_text = 'Last name, first name. Title'
    end
    config.add_search_field('browse_cn') do |field|
      field.include_in_advanced_search = false
      field.label = 'Call number (browse)'
      field.placeholder_text = 'e.g. P19.737.3'
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_start_sort desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'pub_date_start_sort desc, title_sort asc, score desc', label: 'year (newest first)'
    config.add_sort_field 'pub_date_start_sort asc, title_sort asc, score desc', label: 'year (oldest first)'
    config.add_sort_field 'author_sort asc, title_sort asc, score desc', label: 'author'
    config.add_sort_field 'title_sort asc, pub_date_start_sort desc, score desc', label: 'title'
    config.add_sort_field 'cataloged_tdt desc, title_sort asc, score desc', label: 'date cataloged'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 0

    # Add bookmark all widget
    config.add_results_collection_tool(:bookmark_all)

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control')

    config.unapi = {
      'ris' => { content_type: 'application/x-research-info-systems' }
    }
  end

  def render_search_results_as_json
    { response: { docs: @document_list, facets: search_facets_as_json, pages: pagination_info(@response) } }
  end

  def index
    super
  rescue ActionController::BadRequest
    render file: Rails.public_path.join('x400.html'), layout: true, status: :bad_request
  end

  # @see Blacklight::Catalog#facet
  # @see https://github.com/projectblacklight/blacklight/blob/v6.13.0/app/controllers/concerns/blacklight/catalog.rb#L68
  # displays values and pagination links for a single facet field
  def facet
    @facet = blacklight_config.facet_fields[params[:id]]
    raise ActionController::RoutingError, 'Not Found' unless @facet
    @response = get_facet_field_response(@facet.key, params)
    @display_facet = @response.aggregations[@facet.field]
    raise ActionController::RoutingError, 'Not Found' unless @display_facet
    @pagination = facet_paginator(@facet, @display_facet)
    respond_to do |format|
      format.html do
        # Draw the partial for the "more" facet modal window:
        return render layout: false if request.xhr?
        # Otherwise draw the facet selector for users who have javascript disabled.
      end
      format.json
    end
  end
end
