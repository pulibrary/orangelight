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

  # Copied from
  # https://github.com/projectblacklight/blacklight/blob/040933c7a383cd0c5be5895d51ab1004ef3ad5e1/app/controllers/concerns/blacklight/bookmarks.rb#L40-L57
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks
    @response, deprecated_document_list = search_service.fetch(bookmark_ids)
    # <Princeton Modifications>
    # Commented out to use the instance method instead, which adds alma IDs.
    # bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }
    # </Princeton Modifications>
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

  def create
    @bookmarks = if params[:bookmarks]
                   permit_bookmarks[:bookmarks]
                 else
                   [{ document_id: params[:id], document_type: blacklight_config.document_model.to_s }]
                 end

    current_or_guest_user.save! unless current_or_guest_user.persisted?

    bookmarks_to_add = @bookmarks.reject { |bookmark| current_or_guest_user.bookmarks.where(bookmark).exists? }
    success = ActiveRecord::Base.transaction do
      current_or_guest_user.bookmarks.create!(bookmarks_to_add)
    rescue ActiveRecord::RecordInvalid
      false
    end

    if request.xhr?
      success ? render(json: { bookmarks: { count: current_or_guest_user.bookmarks.count } }) : render(json: current_or_guest_user.bookmarks.select(&:invalid?).map{ |g| g.errors.full_messages }, status: "500")
    else
      if @bookmarks.any? && success
        flash[:notice] = I18n.t('blacklight.bookmarks.add.success', count: @bookmarks.length)
      elsif @bookmarks.any?
        flash[:error] = I18n.t('blacklight.bookmarks.add.failure', count: @bookmarks.length)
      end

      redirect_back fallback_location: bookmarks_path
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
      bookmarks.collect { |b| convert_to_alma_id(b.document_id.to_s) }
    end

    def fetch_bookmarked_documents
      _, @documents = search_service.fetch(bookmark_ids, rows: bookmark_ids.length, fl: '*')
    end

    def convert_to_alma_id(id)
      if (id.length < 13) && (id =~ /^\d+$/)
        "99#{id}3506421"
      else
        id
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
end
