# frozen_string_literal: true

class SuggestCorrectionController < ApplicationController
  def suggest_correction
    @form = SuggestCorrectionForm.new(suggestion_params)
    if @form.valid? && @form.submit
      render partial: "catalog/suggest_correction_form", locals: { form: @form }
    else
      render partial: "catalog/suggest_correction_form", locals: { form: @form }, status: :unprocessable_entity
    end
  end

  private
    def suggestion_params
      params[:suggest_correction_form].permit!
    end
end
