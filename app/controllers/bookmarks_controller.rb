# frozen_string_literal: true

require 'csv'
# :reek:TooManyInstanceVariables
class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  configure_blacklight do |_config|
    blacklight_config.show.document_actions[:print] =
      {
        partial: 'document_action',
        name: :print,
        modal: false
      }
  end

  # :reek:TooManyStatements
  # :reek:DuplicateMethodCall
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = @bookmarks.collect { |bookmark| bookmark.document_id.to_s }

    if bookmark_ids.present?
      params[:f] ||= {}
      params[:f][:id] = bookmark_ids
      @response, = search_service.search_results
    else
      @response = Blacklight::Solr::Response.new({ response: { numFound: 0, start: 0, docs: [] } }, {})
    end

    respond_to do |format|
      format.html {}
      format.json { render json: render_search_results_as_json }
    end
  end

  def print
    fetch_bookmarked_documents
    render('orangelight/record_mailer/email_record', formats: [:text])
  end

  def citation
    bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = bookmarks.collect { |bookmark| bookmark.document_id.to_s }
    @documents = search_service.fetch(bookmark_ids, { rows: bookmark_ids.count, fl: "author_citation_display, title_citation_display, pub_citation_display, number_of_pages_citation_display, pub_date_start_sort, edition_display, format" })
  end

  def csv
    fetch_bookmarked_documents
    send_data csv_output, type: 'text/csv', filename: "bookmarks-#{Time.zone.today}.csv"
  end

  private

    # :reek:TooManyStatements
    def fetch_bookmarked_documents
      bookmarks = token_or_current_or_guest_user.bookmarks
      bookmark_ids = bookmarks.collect { |bookmark| bookmark.document_id.to_s }
      bookmark_count = bookmark_ids.length
      search_params = params.to_unsafe_h
      search_params[:f] = { id: bookmark_ids }
      search_params[:rows] = bookmark_count
      q_param = search_params[:q]
      has_query = q_param.present?

      if has_query
        @filtered_bookmark_ids = solr_filtered_bookmark_ids(q_param, bookmark_ids, bookmark_count)
        @documents = fetch_documents(@filtered_bookmark_ids)
      else
        @filtered_bookmark_ids = bookmark_ids
        @documents = fetch_documents(bookmark_ids)
      end
    end

    # byte-order-mark declaring our output as UTF-8 (required for non-ASCII to be handled by Excel)
    def csv_bom
      %w[EF BB BF].map { |a| a.hex.chr }.join
    end

    def csv_fields
      {
        id: 'ID',
        title_citation_display: ['Title', 'Title (Original Script)'],
        author_display: ['Author', 'Author (Original Script)'],
        format: 'Format',
        language_facet: 'Language',
        pub_citation_display: 'Published/Created',
        pub_date_display: 'Date',
        description_display: 'Description',
        series_display: 'Series',
        location: 'Library',
        location_display: 'Location',
        call_number_display: 'Call Number',
        notes_display: 'Notes',
        edition_display: 'Edition'
      }
    end

    def csv_output
      CSV.generate(csv_bom, headers: true) do |csv|
        csv << csv_fields.values.flatten
        @documents.each do |doc|
          csv << csv_fields.keys.map { |field| csv_values(doc, field) }.flatten
        end
      end
    end

    def csv_values(doc, field)
      if csv_fields[field] == 'ID'
        "'#{doc[field]}'"
      elsif csv_fields[field].is_a?(Array)
        two_values(doc[field])
      else
        Array(doc[field]).join('; ')
      end
    end

    def two_values(arr)
      values = arr || ['', '']
      values << '' if values.length == 1
      values.map { |v| v.chomp(' /') }
    end

    # :reek:UtilityFunction
    def solr_filtered_bookmark_ids(q_param, bookmark_ids, bookmark_count)
      solr = Blacklight.default_index.connection
      solr_params = {
        q: q_param.presence || '*:*',
        fq: ["id:(#{bookmark_ids.join(' ')})"],
        fl: 'id',
        rows: bookmark_count
      }
      response = solr.get 'select', params: solr_params
      response['response']['docs'].pluck('id')
    end

    def fetch_documents(ids)
      search_service.fetch(ids, rows: ids.length, fl: '*')
    end
end
