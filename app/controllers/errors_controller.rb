class ErrorsController < ApplicationController
  def error
    render status: :not_found
  end
end
