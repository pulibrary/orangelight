# frozen_string_literal: true

class FeedbackController < ApplicationController
  include ApplicationHelper

  before_action :current_user_email
  before_action :build_feedback_form, only: [:create]
  before_action :build_ask_a_question_form, only: [:ask_a_question]
  before_action :build_suggest_correction_form, only: [:suggest_correction]
  before_action :build_report_biased_results_form, only: [:report_biased_results]

  def new
    @feedback_form = FeedbackForm.new if @feedback_form.nil?
    @feedback_form.current_url = request.referer || root_url
  end

  def create
    respond_to do |format|
      if @feedback_form.valid?
        @feedback_form.deliver
        format.js { flash.now[:notice] = I18n.t('blacklight.feedback.success') }
      else
        format.js { flash.now[:error] = @feedback_form.error_message }
      end
    end
  end

  def ask_a_question; end

  def suggest_correction; end

  def report_biased_results; end

  protected

    def build_feedback_form
      @feedback_form = FeedbackForm.new(feedback_form_params)
      @feedback_form.request = request
      @feedback_form
    end

    def feedback_form_params
      params.require(:feedback_form).permit(:name, :email, :message, :current_url, :feedback_desc)
    end

    def build_ask_a_question_form
      @question_form = AskAQuestionForm.new(
        context: page_url(question_form_params),
        title: question_form_params['title']
      )
    end

    def question_form_params
      params.require(:ask_a_question_form).permit(:id, :title)
    end

    def build_suggest_correction_form
      @suggest_correction_form = SuggestCorrectionForm.new(
        context: page_url(suggest_correction_form_params),
        title: suggest_correction_form_params['title']
      )
    end

    def suggest_correction_form_params
      params.require(:suggest_correction_form).permit(:id, :title)
    end

    def build_report_biased_results_form
      @biased_results_form = ReportBiasedResultsForm.new(
        biased_results_params
      )
    end

    def biased_results_params
      params.require(:report_biased_results_form).permit(:context)
    end

    def search_results_url(_params)
      search_catalog_url(q: biased_results_params['q'])
    end

    def page_url(params)
      solr_document_url(id: params['id'])
    end

    def current_user_email
      return if current_user.nil?
      return if current_user.provider != 'cas'
      @user_email = "#{current_user.uid}@princeton.edu"
      @user_email
    end
end
