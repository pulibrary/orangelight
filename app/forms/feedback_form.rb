# frozen_string_literal: true

require 'mail_form'

class FeedbackForm
  include ActiveModel::Model
  include Honeypot

  attr_accessor :name, :email, :message, :current_url, :request
  validates :name, :email, :message, presence: true
  validates :email, email: true

  def deliver
    ContactMailer.with(form: self).feedback.deliver if valid? && !spam?
  end

  def headers
    {
      subject: "#{I18n.t(:'blacklight.application_name')} Feedback Form",
      to: Orangelight.config["feedback_form"]["to"],
      from: %("#{name}" <#{email}>),
      cc: Orangelight.config["feedback_form"]["cc"]
    }
  end

  def error_message
    I18n.t(:'blacklight.feedback.error').to_s
  end

  def remote_ip
    request&.remote_ip
  end

  def user_agent
    request&.user_agent
  end
end
