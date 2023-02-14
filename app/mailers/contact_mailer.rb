# frozen_string_literal: true
class ContactMailer < ApplicationMailer
  def question
    @form = params[:form]
    mail(to: @form.routed_mail_to, from: @form.email, subject: @form.email_subject)
  end

  def suggestion
    @form = params[:form]
    mail(to: @form.routed_mail_to, from: @form.email, subject: @form.email_subject)
  end

  def harmful_language
    @form = params[:form]
    mail(to: @form.routed_mail_to, from: @form.from_email, subject: @form.email_subject)
  end
end
