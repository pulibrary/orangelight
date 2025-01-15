# frozen_string_literal: true

class FeedbackForm
  include ActiveModel::Model
  include Honeypot

  attr_accessor :name, :email, :message, :current_url, :request
  validates :name, :email, :message, presence: true
  validates :email, email: true

  def deliver
    return if spam?
    return unless valid?

    FeedbackFormSubmission.new(
      message:, patron_name: name, patron_email: email, user_agent:, current_url:
    ).send_to_libanswers
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
