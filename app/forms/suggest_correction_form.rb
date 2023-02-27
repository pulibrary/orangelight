# frozen_string_literal: true

class SuggestCorrectionForm < MailForm::Base
  include ActiveModel::Model
  attr_accessor :name, :email, :message, :context, :title

  validates :name, :email, :message, :context, presence: true
  validates :email, email: true
  attribute :feedback_desc, captcha: true

  def email_subject
    "[Catalog] #{title}"
  end

  def submit
    ContactMailer.with(form: self).suggestion.deliver unless spam?
    @submitted = true
    @name = ""
    @email = ""
    @message = ""
  end

  def submitted?
    @submitted == true
  end

  def routed_mail_to
    Orangelight.config["suggest_correction_form"]["to"]
  end
end
