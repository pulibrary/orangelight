# frozen_string_literal: true

class Orangelight::RecordMailer < RecordMailer
  def email_record(documents, details, url_gen_params)
    begin
      title_field = details[:config].email.title_field
      if title_field
        [documents.first[title_field]].flatten.first
      else
        documents.first.to_semantic_values[:title]
      end
    rescue StandardError
      I18n.t('blacklight.email.text.default_title')
    end

    subject = if details[:subject]&.first.present?
                details[:subject].first
              else
                I18n.t('blacklight.email.text.subject', count: documents.length, title: '')
              end

    @documents      = documents
    @message        = details[:message]
    @config         = details[:config]
    @url_gen_params = url_gen_params

    mail(to: details[:to], reply_to: details[:reply_to], subject:)
  end
end
