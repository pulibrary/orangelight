# frozen_string_literal: true
class ReportHarmfulLanguageForm
  include ActiveModel::Model
  include Honeypot
  attr_accessor :name, :email, :message, :context, :title, :error

  validates :message, presence: true

  def submit
    if /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i.match?(email) || email&.empty?
      unless spam?
        RecordFeedbackFormSubmission.new(
          patron_name: name,
          patron_email: email,
          message:,
          title: "[Possible Harmful Language] #{title}",
          context:,
          quid: Rails.application.config_for(:orangelight)[:report_harmful_language_form][:queue_id]
        ).send_to_libanswers
      end
      @submitted = true
      @name = ""
      @email = ""
      @message = ""
    else
      @submitted = false
      @errors.add(:email, :invalid, message: "is not a valid email address")
      false
    end
  end

  def submitted?
    @submitted == true
  end

  def routed_mail_to
    Orangelight.config["report_harmful_language_form"]["to"]
  end

  # If the form does not include an email, use the routed_mail_to email for the "from" field
  def from_email
    @from_email ||= @email.presence || routed_mail_to
  end
end
