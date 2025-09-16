# frozen_string_literal: true
require 'faraday'

include Requests::ApplicationHelper

module Requests
  class FormController < ApplicationController
    before_action :authenticate_user!, except: [:index], unless: -> { aeon? }

    def index
      redirect_to('/')
    end

    def generate
      system_id = sanitize(params[:system_id])
      mfhd = sanitize(params[:mfhd])
      params.require(:mfhd) unless system_id.starts_with?("SCSB") # there are not multiple locations for shared items so no MFHD is passed
      @back_to_record_url = BackToRecordUrl.new(params)

      @user = current_or_guest_user

      @patron = Patron.authorize(user: @user)
      patron_errors = @patron.errors
      flash.now[:error] = patron_errors.join(", ") if patron_errors.present?

      @title = "Request ID: #{system_id}"

      # needed to see if we can suppress login for this item
      @request = FormDecorator.new(Requests::Form.new(system_id:, mfhd:, patron: @patron), view_context, @back_to_record_url)
    rescue ActionController::ParameterMissing
      render 'requests/form/no_location_specified'
    end

    def aeon?
      return true if params["aeon"] == 'true'

      false
    end

    # will post and a JSON document of selected "requestable" objects with selection parameters and
    # user information for further processing and distribution to various request endpoints.
    def submit
      @submission = Requests::Submission.new(sanitize_submission(params), Patron.new(user: current_or_guest_user))
      respond_to do |format|
        format.js do
          valid = @submission.valid?
          @services = @submission.process_submission if valid
          if valid && @submission.service_errors.blank?
            respond_to_submit_success(@submission)
          elsif valid # submission was valid, but service failed
            respond_to_service_error(@services)
          else
            respond_to_validation_error(@submission)
          end
        end
      end
    end

    private

      def mode
        return 'standard' if params[:mode].nil?
        sanitize(params[:mode])
      end

      # trusted params
      def request_params
        params.permit(:id, :system_id, :mfhd, :user_name, :email, :loc_code, :user, :requestable, :request, :barcode, :isbns).permit!
      end

      def sanitize_submission(params)
        params[:requestable].each do |requestable|
          params['user_supplied_enum'] = sanitize(requestable['user_supplied_enum']) if requestable.key? 'user_supplied_enum'
        end
        lparams = params.permit(bib: [:id, :title, :author, :isbn, :date])
        lparams[:requestable] = params[:requestable].map do |requestable|
          json_pick_up = requestable[:pick_up]
          requestable = requestable.merge(JSON.parse(json_pick_up)) if json_pick_up.present?
          requestable.permit!
        end
        lparams
      end

      def respond_to_submit_success(submission)
        flash.now[:success] = submission.success_messages.join(' ')
        # TODO: Why does this go into an infinite loop
        # logger.info "#Request Submission - #{submission.as_json}"
        logger.info "Request Sent"
      end

      def respond_to_service_error(services)
        errors = services.map(&:errors).flatten
        error_types = errors.pluck(:type).uniq
        flash.now[:error] = if error_types.include?("digitize")
                              errors[error_types.index("digitize")][:error]
                            else
                              I18n.t('requests.submit.service_error')
                            end
        logger.error "Request Service Error"
        service_errors = services.map(&:error_hash).inject(:merge)
        send_error_email(service_errors, @submission)
      end

      def respond_to_validation_error(submission)
        flash.now[:error] = I18n.t('requests.submit.error')
        logger.error "Request Submission #{submission.errors.messages.as_json}"
      end

      def sanitize(str)
        # rubocop:disable Style/RedundantRegexpEscape
        str.gsub(/[^A-Za-z0-9@\-_\.]/, '') if str.is_a? String
        # rubocop:enable Style/RedundantRegexpEscape
        str
      end

      # This has to be a utility function to prevent ActiveJob from trying to serialize too many objects
      # :reek:UtilityFunction
      def send_error_email(errors, submission)
        Requests::RequestMailer.send("service_error_email", errors, submission.to_h).deliver_later
      end
  end
end
