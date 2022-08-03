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
    if referrer.present? && (!referrer.include?("sign_in") && !origin&.include?("redirect-to-alma"))
      referrer
    elsif origin.present?
      request.flash.delete('alert')
      request.flash.keep('notice')
      origin.chomp('/email')
    elsif !request.env['omniauth.origin'].nil? &&
          /request|borrow-direct|email|bookmarks|search_history|redirect-to-alma/.match(request.env['omniauth.origin'])
      request.env['omniauth.origin']
    else
      account_path
    end
  end

  def referrer
    @referrer ||= params[:url] || request.referer
  end

  def origin
    @origin ||= begin
      return params[:origin] if params[:origin].present?

      if referrer.present? && referrer.include?("origin")
        referrer_params = Rack::Utils.parse_query URI.parse(referrer).query
        return referrer_params["origin"]
      end
    end
  end

  def after_sign_out_path_for(resource)
    if resource == 'barcode' || resource == "alma"
      root_url
    else
      Rails.configuration.x.after_sign_out_url
    end
  end

  def default_url_options
    Rails.env.production? || Rails.env.staging? ? { protocol: 'https' } : {}
  end
end
