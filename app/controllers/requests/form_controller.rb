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
      # Patron can be slow to load, start loading it early
      @user = current_or_guest_user
      patron_request = Thread.new { Patron.authorize(user: @user) }

      system_id = sanitize(params[:system_id])
      mfhd = sanitize(params[:mfhd])
      params.require(:mfhd) unless system_id.starts_with?("SCSB") # there are not multiple locations for shared items so no MFHD is passed
      @back_to_record_url = BackToRecordUrl.new(params)

      @title = "Request ID: #{system_id}"

      # needed to see if we can suppress login for this item
      @request = FormDecorator.new(Requests::Form.new(system_id:, mfhd:, patron_request:), view_context, @back_to_record_url)
      @patron = patron_request.value
      patron_errors = @patron.errors
      flash.now[:error] = patron_errors.join(", ") if patron_errors.present?
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

      valid = @submission.valid?
      @services = @submission.process_submission if valid

      response_data = if valid && @submission.service_errors.blank?
                        respond_to_submit_success(@submission)
                      elsif valid # submission was valid, but service failed
                        respond_to_service_error(@services)
                      else
                        respond_to_validation_error(@submission)
                      end

      render json: response_data
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

      # :reek:UncommunicativeVariableName { accept: ['e'] }
      # :reek:TooManyStatements
      def respond_to_submit_success(submission)
        success_message = submission.success_messages.join(' ')
        flash.now[:success] = success_message
        logger.info "Request Sent"

        {
          success: true,
          message: success_message
        }
      end

      # :reek:UncommunicativeVariableName { accept: ['e'] }
      def respond_to_service_error(services)
        errors = services.map(&:errors).flatten
        error_types = errors.pluck(:type).uniq
        flash_now_error = if error_types.include?("digitize")
                            errors[error_types.index("digitize")][:error]
                          else
                            I18n.t('requests.submit.service_error')
                          end
        flash.now[:error] = flash_now_error
        logger.error "Request Service Error"
        service_errors = services.map(&:error_hash).inject(:merge)
        send_error_email(service_errors, @submission)

        {
          success: false,
          message: flash_now_error,
          errors: service_errors
        }
      end

      # :reek:TooManyStatements
      def respond_to_validation_error(submission)
        error_message = I18n.t('requests.submit.error')
        error_messages = submission.errors.messages

        flash.now[:error] = error_message
        logger.error "Request Submission #{error_messages.as_json}"

        {
          success: false,
          message: error_message,
          errors: format_validation_errors(error_messages)
        }
      end

      def sanitize(str)
        str.gsub(/[^A-Za-z0-9@\-_\.]/, '') if str.is_a? String
        str
      end

      # :reek:NestedIterators
      # :reek:TooManyStatements
      # :reek:UtilityFunction
      def format_validation_errors(error_messages)
        formatted_errors = {}

        error_messages.each do |key, values|
          formatted_errors[key] = if key == :items
                                    # Handle special items field format
                                    values.map do |value|
                                      if value.is_a?(Hash)
                                        first_value = value.values.first
                                        {
                                          key: value.keys.first,
                                          type: first_value['type'],
                                          text: first_value['text']
                                        }
                                      else
                                        { text: value }
                                      end
                                    end
                                  else
                                    # Handle regular validation errors
                                    values
                                  end
        end
        formatted_errors
      end

      # This has to be a utility function to prevent ActiveJob from trying to serialize too many objects
      # :reek:UtilityFunction
      def send_error_email(errors, submission)
        Requests::RequestMailer.send("service_error_email", errors, submission.to_h).deliver_later
      end
  end
end
