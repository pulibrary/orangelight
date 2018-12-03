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

    def fetch_bookmarked_documents
      bookmarks = token_or_current_or_guest_user.bookmarks
      bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }
      _, @documents = fetch(bookmark_ids, rows: bookmark_ids.length)
    end

    # byte-order-mark declaring our output as UTF-8 (required for non-ASCII to be handled by Excel)
    def csv_bom
      %w[EF BB BF].map { |a| a.hex.chr }.join
    end

    def csv_fields
      {
        id: 'ID',
        title_citation_display: 'Title',
        author_display: 'Author',
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
        csv << csv_fields.values
        @documents.each do |doc|
          csv << csv_fields.keys.map { |field| Array(doc[field]).join('; ') }
        end
      end
    end
end
