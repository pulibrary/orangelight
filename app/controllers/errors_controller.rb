# frozen_string_literal: true

class ErrorsController < ApplicationController
  def error
    render status: :internal_server_error
  end

  def missing
    render status: :not_found
  end
end
