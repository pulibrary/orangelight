# frozen_string_literal: true
module Requests
  class RequestMailer < ApplicationMailer
    include Requests::Bibdata
    helper "requests/application"

    def digitize_fill_in_confirmation(submission)
      @submission = submission
      @delivery_mode = "edd"
      subject = I18n.t('requests.paging.email_subject', pick_up_location: "Digitization")
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def paging_email(submission)
      @submission = submission
      pick_ups = paging_pick_ups(submission: submission)
      subject = I18n.t('requests.paging.email_subject', pick_up_location: pick_ups.join(", "))
      destination_email = "fstpage@princeton.edu"
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def paging_confirmation(submission)
      @submission = submission
      pick_ups = paging_pick_ups(submission: submission)
      subject = I18n.t('requests.paging.email_subject', pick_up_location: pick_ups.join(", "))
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def pres_email(submission)
      request_email(submission: submission, subject_key: 'requests.pres.email_subject', destination_key: 'requests.pres.email')
    end

    def pres_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.pres.email_subject')
    end

    def annex_email(submission)
      @submission = submission
      destination_email = annex_email_destinations(submission: @submission)
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annex.email_subject'), @submission.user_barcode))
    end

    def annex_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.annex.email_subject')
    end

    def annex_in_library_email(submission)
      @submission = submission
      mail(to: I18n.t('requests.annex.email'),
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.annex_in_library.email_subject'), @submission.user_barcode))
    end

    def annex_in_library_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.annex_in_library.email_subject')
    end

    def annex_edd_email(submission); end

    def annex_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.recap_edd.email_subject', partial: 'recap_edd_confirmation')
    end

    def ppl_email(submission)
      request_email(submission: submission, subject_key: 'requests.ppl.email_subject', destination_key: 'requests.ppl.email')
    end

    def ppl_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(I18n.t('requests.ppl.email_subject'), @submission.user_barcode))
    end

    # temporary changes issue 438
    def on_shelf_email(submission)
      location_email = get_location_contact_email(submission.items.first[:location_code])
      @submission = submission
      # Location and destination are the same forthe moment
      # destination_email = I18n.t('requests.on_shelf.email')
      subject = "#{subject_line(I18n.t('requests.on_shelf.email_subject'), @submission.user_barcode)} (#{submission.items.first[:location_code].upcase}) #{submission.items.first[:call_number]}"
      mail(to: location_email,
           # cc: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    # temporary changes issue 438
    def on_shelf_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = "#{Requests::BibdataService.delivery_locations[@submission.items.first['pick_up']]['label']} #{I18n.t('requests.on_shelf.email_subject_patron')}"
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject_line(subject, @submission.user_barcode))
    end

    def on_order_email(submission)
      destination_key = if submission.marquand?
                          'requests.marquand_in_process.email_destination'
                        else
                          'requests.default.email_destination'
                        end
      request_email(submission: submission, subject_key: 'requests.on_order.email_subject', destination_key: destination_key)
    end

    def on_order_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.on_order.email_subject')
    end

    def in_process_email(submission)
      destination_key = if submission.marquand?
                          'requests.marquand_in_process.email_destination'
                        else
                          'requests.default.email_destination'
                        end
      request_email(submission: submission, subject_key: 'requests.in_process.email_subject', destination_key: destination_key)
    end

    def in_process_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.in_process.email_subject')
    end

    def trace_email(submission)
      request_email(submission: submission, subject_key: 'requests.trace.email_subject')
    end

    def trace_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.trace.email_subject')
    end

    def recap_no_items_email(submission)
      request_email(submission: submission, subject_key: 'requests.recap_no_items.email_subject', destination_key: 'requests.recap_no_items.email')
    end

    def recap_no_items_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.recap.email_subject')
      if @submission.access_only?
        cc_email = I18n.t('requests.recap.guest_email_destination')
        subject = I18n.t('requests.recap_guest.email_subject')
      end
      mail(to: destination_email,
           cc: cc_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    def digitize_email(submission)
      # TODO: what should we do here
    end

    def digitize_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.digitize.email_subject', from_key: 'requests.digitize.email_from')
    end

    def interlibrary_loan_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.interlibrary_loan.email_subject', from_key: 'requests.interlibrary_loan.email_from')
    end

    def recap_email(submission)
      # only send an email to the libraries if this is a barcode user request
      return unless submission.access_only?
      request_email(submission: submission, subject_key: 'requests.recap_guest.email_subject', destination_key: 'requests.recap.guest_email_destination')
    end

    def recap_confirmation(submission)
      subject_key = 'requests.recap.email_subject'
      subject_key = 'requests.recap_guest.email_subject' if submission.access_only?

      confirmation_email(submission: submission, subject_key: subject_key)
    end

    def recap_marquand_edd_email(submission); end

    def recap_marquand_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.recap_edd.email_subject', partial: 'recap_edd_confirmation')
    end

    def recap_marquand_in_library_email(submission); end

    def recap_marquand_in_library_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.recap_in_library.email_subject')
    end

    def recap_in_library_email(submission)
      # only send an email to the libraries if this is a barcode user request or marquand
      if submission.access_only?
        request_email(submission: submission, subject_key: 'requests.recap_guest.email_subject', destination_key: 'requests.recap.guest_email_destination')
      elsif submission.marquand?
        request_email(submission: submission, subject_key: 'requests.recap_marquand.email_subject', destination_key: 'requests.recap_marquand.email_destination')
      end
    end

    def recap_in_library_confirmation(submission)
      subject_key = 'requests.recap_in_library.email_subject'
      subject_key = 'requests.recap_guest.email_subject' if submission.access_only?

      confirmation_email(submission: submission, subject_key: subject_key)
    end

    def recap_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.recap_edd.email_subject')
    end

    def clancy_in_library_email(submission)
      request_email(submission: submission, subject_key: 'requests.clancy_in_library.email_subject', destination_key: 'requests.clancy_in_library.email_destination')
    end

    def clancy_in_library_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.clancy_in_library.confirmation_subject')
    end

    def clancy_unavailable_edd_email(submission)
      request_email(submission: submission, subject_key: 'requests.clancy_unavailable_edd.email_subject', destination_key: 'requests.clancy_unavailable_edd.email_destination')
    end

    def clancy_unavailable_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.clancy_unavailable_edd.confirmation_subject')
    end

    def clancy_edd_email(submission)
      request_email(submission: submission, subject_key: 'requests.clancy_edd.email_subject', destination_key: 'requests.clancy_edd.email_destination')
    end

    def clancy_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.clancy_edd.confirmation_subject')
    end

    def marquand_edd_email(submission)
      request_email(submission: submission, subject_key: 'requests.marquand_edd.email_subject', destination_key: 'requests.marquand_edd.email_destination')
    end

    def marquand_edd_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.marquand_edd.confirmation_subject')
    end

    def marquand_in_library_email(submission)
      request_email(submission: submission, subject_key: 'requests.marquand_in_library.email_subject', destination_key: 'requests.marquand_in_library.email_destination')
    end

    def marquand_in_library_confirmation(submission)
      confirmation_email(submission: submission, subject_key: 'requests.marquand_in_library.confirmation_subject')
    end

    def service_error_email(services, submission)
      @services = services
      @submission = submission
      errors = services.map(&:errors).flatten
      error_types = errors.map { |error| error[:type] }.uniq
      destination_email = if error_types.include?("digitize")
                            I18n.t('requests.digitize.invalid_patron.email')
                          else
                            I18n.t('requests.error.service_error_email')
                          end
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.error.service_error_subject'))
    end

    def invalid_illiad_patron_email(user_attributes, transaction_attributes)
      @user_attributes = user_attributes
      @transaction_attributes = transaction_attributes
      destination_email = I18n.t('requests.digitize.invalid_patron.email')
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: I18n.t('requests.digitize.invalid_patron.subject'))
    end

    def help_me_email(submission)
      # TODO: what should we do for access only users
    end

    def help_me_confirmation(submission)
      @submission = submission
      destination_email = @submission.email
      subject = I18n.t('requests.help_me.email_subject')
      subject = I18n.t('requests.help_me_guest.email_subject') if @submission.access_only?
      mail(to: destination_email,
           from: I18n.t('requests.default.email_from'),
           subject: subject)
    end

    private

      def confirmation_email(submission:, subject_key:, from_key: 'requests.default.email_from', partial: nil)
        @submission = submission
        destination_email = @submission.email
        subject = I18n.t(subject_key)
        mail(to: destination_email,
             from: I18n.t(from_key),
             subject: subject,
             template_name: partial)
      end

      def request_email(submission:, subject_key:, destination_key: 'requests.default.email_destination', from_key: 'requests.default.email_from')
        @submission = submission
        destination_email = I18n.t(destination_key)
        mail(to: destination_email,
             from: I18n.t(from_key),
             subject: subject_line(I18n.t(subject_key), @submission.user_barcode))
      end

      def paging_pick_ups(submission:)
        @delivery_mode = submission.items[0]["delivery_mode_#{submission.items[0]['mfhd']}"]
        if @delivery_mode == "edd"
          ["Digitization"]
        else
          @submission.items.map { |item| Requests::BibdataService.delivery_locations[item["pick_up"]]["label"] }
        end
      end

      def annex_email_destinations(submission:)
        annex_items(submission: submission).map do |item|
          if item["location_code"] == 'annex$doc'
            I18n.t('requests.anxadoc.email')
          else
            I18n.t('requests.annex.email')
          end
        end
      end

      def annex_items(submission:)
        submission.items.select { |item| item["type"] == 'annex' }
      end

      def subject_line(request_subject, barcode)
        if barcode == 'ACCESS' || barcode == 'access'
          "#{request_subject} - ACCESS"
        else
          request_subject
        end
      end
  end
end
