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
        flash_now_error('There was a problem submitting your question')
      end
    rescue StandardError => e
      flash_now_error('There was a problem submitting your question')
      Rails.logger.error("AskAQuestion submission failed: #{e.class} - #{e.message}")
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
        flash_now_error('There was a problem submitting your suggestion')
      end
    rescue StandardError => e
      flash_now_error('There was a problem submitting your suggestion')
      Rails.logger.error("SuggestCorrection submission failed: #{e.class} - #{e.message}")
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
        flash_now_error('There was a problem submitting your missing item report')
      end
    rescue StandardError => e
      flash_now_error('There was a problem submitting your missing item report')
      Rails.logger.error("MissingItem submission failed: #{e.class} - #{e.message}")
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
