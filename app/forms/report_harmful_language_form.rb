# frozen_string_literal: true
class ReportHarmfulLanguageForm
  include ActiveModel::Model
  attr_accessor :name, :email, :message, :context, :title

  validates :message, presence: true

  def email_subject
    "[Possible Harmful Language] #{title}"
  end

  def submit
    ContactMailer.with(form: self).harmful_language.deliver
    @submitted = true
    @name = ""
    @email = ""
    @message = ""
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
