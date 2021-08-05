# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error
    render status: 500
  end

  def missing
    render status: :not_found
  end
end
