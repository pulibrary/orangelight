# frozen_string_literal: true
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
    bookmarks = token_or_current_or_guest_user.bookmarks
    bookmark_ids = bookmarks.collect { |b| b.document_id.to_s }

    _, @documents = fetch(bookmark_ids)
    @url_gen_params = {}
    render 'record_mailer/email_record.text.erb', template: false, content_type: 'text/plain'
  end
end
