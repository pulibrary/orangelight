# frozen_string_literal: true

class SuggestCorrectionForm
  include ActiveModel::Model
  include Honeypot

  attr_accessor :name, :email, :message, :context, :title

  validates :name, :email, :message, :context, presence: true
  validates :email, email: true

  def submit
    unless spam?
      RecordFeedbackFormSubmission.new(
        message:,
        patron_name: name,
        patron_email: email,
        title: "[Catalog] #{title}",
        context:,
        quid: Rails.application.config_for(:orangelight)[:suggest_correction_form][:queue_id]
      ).send_to_libanswers
    end
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
