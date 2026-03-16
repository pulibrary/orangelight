# frozen_string_literal: true
class ContactController < ApplicationController
  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  # :reek:UncommunicativeVariableName
  def question
    @form = AskAQuestionForm.new(question_params)
    begin
      if @form.valid? && @form.submit
        flash_now_success('Your question has been submitted')
      else
        flash_now_error(t('blacklight.ask_a_question.form.ticket_submission_error'))
      end
    rescue StandardError
      flash_now_error(t('blacklight.ask_a_question.form.ticket_submission_error'))
      Rails.logger.error(t('blacklight.ask_a_question.form.ticket_submission_error'))
    end
    respond_to do |format|
      format.js
    end
  end

  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  # :reek:UncommunicativeVariableName
  def suggestion
    @form = SuggestCorrectionForm.new(suggestion_params)
    begin
      if @form.valid? && @form.submit
        flash_now_success('Your suggestion has been submitted')
      else
        flash_now_error(t('blacklight.suggest_correction.form.ticket_submission_error'))
      end
    rescue StandardError
      flash_now_error(t('blacklight.suggest_correction.form.ticket_submission_error'))
      Rails.logger.error(t('blacklight.suggest_correction.form.ticket_submission_error'))
    end
    respond_to do |format|
      format.js
    end
  end

  # :reek:DuplicateMethodCall
  # :reek:TooManyStatements
  # :reek:UncommunicativeVariableName
  def missing_item
    @form = MissingItemForm.new(missing_item_params)
    begin
      if @form.valid? && @form.submit
        flash_now_success('Your missing item report has been submitted')
      else
        flash_now_error(t('blacklight.missing_item.form.ticket_submission_error'))
      end
    rescue StandardError
      flash_now_error(t('blacklight.missing_item.form.ticket_submission_error'))
      Rails.logger.error(t('blacklight.missing_item.form.ticket_submission_error'))
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def question_params
      params[:ask_a_question_form].permit!
    end

    def suggestion_params
      params[:suggest_correction_form].permit!
    end

    def missing_item_params
      params[:missing_item_form].permit!
    end

    def flash_now_error(message)
      flash.now[:error] = message
    end

    def flash_now_success(message)
      flash.now[:success] = message
    end
end
