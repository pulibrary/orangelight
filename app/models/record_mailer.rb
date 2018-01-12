# frozen_string_literal: true

# Only works for documents with a #to_marc right now.
class RecordMailer < ActionMailer::Base
  def email_record(documents, details, url_gen_params)
    subject = if details[:subject]&.first.present?
                details[:subject].first
              else
                I18n.t('blacklight.email.text.subject', count: documents.length, title: '')
              end

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(to: details[:to], reply_to: details[:reply_to], subject: subject)
  end

  def sms_record(documents, details, url_gen_params)
    @documents      = documents
    @url_gen_params = url_gen_params
    mail(to: details[:to], subject: '')
  end
end
