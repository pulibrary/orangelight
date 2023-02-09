# frozen_string_literal: true
class ContactController < ApplicationController
  def question
    @form = AskAQuestionForm.new(question_params)
    if @form.valid? && @form.submit
      flash[:success] = 'Your question has been submitted'

      render "question_success"
    else
      render partial: "catalog/ask_a_question_form", locals: { form: @form }, status: :unprocessable_entity
    end
  end

  def report_harmful_language
    @form = ReportHarmfulLanguageForm.new(report_harmful_language_params)
    if @form.valid? && @form.submit
      flash[:success] = 'Your report has been submitted'

      render "report_harmful_language_success"
    else
      render partial: "catalog/ask_a_question_form", locals: { form: @form }, status: :unprocessable_entity
    end
  end

  private

    def question_params
      params[:ask_a_question_form].permit!
    end

    def report_harmful_language_params
      params[:report_harmful_language_form].permit!
    end
end
