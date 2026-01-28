# frozen_string_literal: true
class ContactController < ApplicationController
  def question
    @form = AskAQuestionForm.new(question_params)
    if @form.valid? && @form.submit
      flash[:success] = 'Your question has been submitted'

      render "question_success"
    else
      render partial: "catalog/ask_a_question_form", locals: { form: @form }, status: :unprocessable_content
    end
  end

  def suggestion
    @form = SuggestCorrectionForm.new(suggestion_params)
    if @form.valid? && @form.submit
      flash[:success] = 'Your suggestion has been submitted'

      render "suggestion_success"
    else
      render partial: "catalog/suggest_correction_form", locals: { form: @form }, status: :unprocessable_content
    end
  end

  def missing_item
    @form = MissingItemForm.new(missing_item_params)
    if @form.valid? && @form.submit
      flash[:success] = 'Your feedback has been submitted'

      render "missing_item_success"
    else
      render partial: "catalog/missing_item_form", locals: { form: @form }, status: :unprocessable_content
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
end
