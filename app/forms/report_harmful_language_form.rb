# frozen_string_literal: true
class ReportHarmfulLanguageForm < MailForm::Base
  include ActiveModel::Model
  attr_accessor :name, :email, :message, :context, :title, :error

  validates :message, presence: true
  attribute :feedback_desc, captcha: true

  def email_subject
    "[Possible Harmful Language] #{title}"
  end

  def submit
    if /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i === self.email || self.email.empty?
      ContactMailer.with(form: self).harmful_language.deliver unless spam?
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
