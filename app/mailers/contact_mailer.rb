# frozen_string_literal: true
class ContactMailer < ApplicationMailer
  def biased_results
    @form = params[:form]
    mail(to: @form.routed_mail_to, from: @form.from_email, subject: @form.email_subject)
  end
end
