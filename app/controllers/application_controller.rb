class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # include Blacklight::Folders::ApplicationControllerBehavior

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(_resource)
    if !request.env['omniauth.origin'].nil? && request.env['omniauth.origin'].include?('requests')
      request.env['omniauth.origin']
    else
      account_path
    end
  end

  def after_sign_out_path_for(_resource)
    Rails.configuration.x.after_sign_out_url
  end
end
