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

  private

    def question_params
      params[:ask_a_question_form].permit!
    end
end
