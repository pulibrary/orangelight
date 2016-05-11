class ErrorsController < ApplicationController
  def error
    render status: :error
  end

  def missing
    render status: :not_found
  end
end
