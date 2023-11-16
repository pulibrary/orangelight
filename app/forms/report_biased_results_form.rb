# frozen_string_literal: true
class ReportBiasedResultsForm < MailForm::Base
  include ActiveModel::Model
  attr_accessor :name, :email, :message, :context

  validates :message, presence: true
  attribute :feedback_desc, captcha: true

  def email_subject
    "[Possible Biased Results]"
  end

  def submit
    ContactMailer.with(form: self).biased_results.deliver unless spam?
    @submitted = true
    @name = ""
    @email = ""
    @message = ""
  end

  def submitted?
    @submitted == true
  end

  def routed_mail_to
    Orangelight.config["report_biased_results_form"]["to"]
  end

  # If the form does not include an email, use the routed_mail_to email for the "from" field
  def from_email
    @from_email ||= @email.presence || routed_mail_to
  end
end
