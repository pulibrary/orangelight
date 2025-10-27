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

    def alma
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
      mail = Orangelight::RecordMailer.email_record(documents, { to: params[:to], reply_to: user_email, message: params[:message], subject: params[:subject] }, url_options)
      if mail.respond_to? :deliver_later
        mail.deliver_later
      else
        mail.deliver
      end
    end

    # rubocop:disable Naming/PredicateMethod
    def validate_email_params
      if current_user.nil?
        flash[:error] = 'You must be logged in to send an email.'
      elsif params[:to].blank?
        flash[:error] = I18n.t('blacklight.email.errors.to.blank')
      elsif !params[:to].match(Blacklight::Engine.config.blacklight.email_regexp)
        flash[:error] = I18n.t('blacklight.email.errors.to.invalid', to: params[:to])
      end

      flash[:error].blank?
    end
    # rubocop:enable Naming/PredicateMethod

    def user_email
      return current_user.email if current_or_guest_user.cas_provider?
    end

    def show_location_has?(_field_config, document)
      any_location_notes = document.holdings_1display.any? { |_key, value| value[:location_has] }
      document[:electronic_access_1display].present? && any_location_notes && document[:location].blank?
    end

    def linked_records
      return head(:bad_request) unless params[:id] && params[:field]

      begin
        document = search_service.fetch(params[:id])
      rescue Blacklight::Exceptions::RecordNotFound
        return head(:bad_request)
      end

      render json: document.linked_records(field: params[:field], maximum_records: 500).decorated
    end
  end
end
