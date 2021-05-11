# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(_resource)
    if params[:origin]
      request.flash.delete('alert')
      request.flash.keep('notice')
      params[:origin].chomp('/email')
    elsif !request.env['omniauth.origin'].nil? &&
          /request|borrow-direct|email|bookmarks/.match(request.env['omniauth.origin'])
      request.env['omniauth.origin']
    else
      account_path
    end
  end

  def after_sign_out_path_for(resource)
    if resource == 'barcode'
      root_url
    else
      Rails.configuration.x.after_sign_out_url
    end
  end

  def default_url_options
    Rails.env.production? || Rails.env.staging? ? { protocol: 'https' } : {}
  end
end
