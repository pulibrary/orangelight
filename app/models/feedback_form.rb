# frozen_string_literal: true

require 'mail_form'

class FeedbackForm < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message, validate: true
  attribute :current_url
  attribute :feedback_desc, captcha: true
  append :remote_ip, :user_agent

  def headers
    {
      subject: "#{I18n.t(:'blacklight.application_name')} Feedback Form",
      to: ENV['OL_FEEDBACK_TO'] || 'test@princeton.edu',
      from: %("#{name}" <#{email}>),
      cc: ENV['OL_FEEDBACK_CC'] || 'test2w@princeton.edu, test3@princeton.edu'
    }
  end

  def error_message
    I18n.t(:'blacklight.feedback.error').to_s
  end
end
