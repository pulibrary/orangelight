# frozen_string_literal: true

module Orangelight
  module Catalog
    extend ActiveSupport::Concern

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

    def voyager
      bib_id = params[:BBID] || params[:bbid]
      redirect_to "/catalog/#{bib_id}"
    end

    def redirect_browse
      if params[:search_field] && params[:controller] != 'advanced'
        if params[:search_field] == 'browse_subject' && !params[:id]
          redirect_to "/browse/subjects?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        elsif params[:search_field] == 'browse_cn' && !params[:id]
          redirect_to "/browse/call_numbers?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        elsif params[:search_field] == 'browse_name' && !params[:id]
          redirect_to "/browse/names?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        elsif params[:search_field] == 'name_title' && !params[:id]
          redirect_to "/browse/name_titles?search_field=#{params[:search_field]}&q=#{CGI.escape params[:q]}"
        end
      end
    end

    # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
    def email_action(documents)
      mail = RecordMailer.email_record(documents, { to: params[:to], reply_to: user_email, message: params[:message], subject: params[:subject] }, url_options)
      if mail.respond_to? :deliver_now
        mail.deliver_now
      else
        mail.deliver
      end
    end

    def user_email
      return current_user.email if current_or_guest_user.provider == 'cas'
    end

    def online_holding_note?(_field_config, document)
      location_notes = JSON.parse(document[:holdings_1display] || '{}').collect { |_k, v| v['location_has'] }
      document[:electronic_access_1display].present? && location_notes.any?
    end
  end
end
