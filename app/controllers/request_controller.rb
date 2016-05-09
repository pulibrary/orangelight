class RequestController < ApplicationController
  include ApplicationHelper

  def show
    @id = sanitize(params[:id])
  end

  private

    def sanitize(str)
      str.gsub(/[^A-Za-z0-9]/, '')
    end
end
