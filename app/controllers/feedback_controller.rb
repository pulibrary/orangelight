# frozen_string_literal: true

class FeedbackController < ApplicationController
  include ApplicationHelper

  before_action :current_user_email
  before_action :build_feedback_form, only: [:create]
  before_action :build_ask_a_question_form, only: [:ask_a_question]

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

  def ask_a_question
    respond_to do |format|
      format.html
      format.js
    end
  end

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
