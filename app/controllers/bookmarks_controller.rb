# frozen_string_literal: true

require 'csv'

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

  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks
    @response, deprecated_document_list = search_service.fetch(bookmark_ids)
    @document_list = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_document_list, "The @document_list instance variable is now deprecated and will be removed in Blacklight 8.0")
    respond_to do |format|
      format.html {}
      format.rss  { render layout: false }
      format.atom { render layout: false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def print
    fetch_bookmarked_documents
    @url_gen_params = {}
    render 'record_mailer/email_record.text.erb', template: false, content_type: 'text/plain'
  end

  def csv
    fetch_bookmarked_documents
    send_data csv_output, type: 'text/csv', filename: "bookmarks-#{Time.zone.today}.csv"
  end

  private

    def bookmark_ids
      bookmarks = token_or_current_or_guest_user.bookmarks
      bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }
      bookmark_ids + alma_ids(bookmark_ids)
    end

    def fetch_bookmarked_documents
      _, @documents = search_service.fetch(bookmark_ids, rows: bookmark_ids.length, fl: '*')
    end

    def alma_ids(bookmark_ids)
      bookmark_ids.map do |id|
        "99#{id}3506421"
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
        location_display: 'Location',
        call_number_display: 'Call Number',
        notes_display: 'Notes'
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
      csv_fields[field].is_a?(Array) ? two_values(doc[field]) : Array(doc[field]).join('; ')
    end

    def two_values(arr)
      values = arr || ['', '']
      values << '' if values.length == 1
      values.map { |v| v.chomp(' /') }
    end
end
