require './lib/orangelight/voyager_client.rb'

class AccountController < ApplicationController
  include Blacklight::Configurable
  include ApplicationHelper

  # copied from saved searches
  copy_blacklight_config_from(CatalogController)
  before_filter :require_user_authentication_provider
  before_filter :verify_user 
  
  def index
    set_patron
    current_account
  end

  def renew
    set_patron
    account_client
    @voyager_client.renewal_request(params[:renew_items])
  end

  def cancel
    set_patron
    account_client
    @voyager_client.cancel_active_requests(params[:cancel_requests])
  end

  protected
  def verify_user
    flash[:notice] = I18n.t('blacklight.saved_searches.need_login') and raise Blacklight::Exceptions::AccessDenied unless current_user
  end

  def set_patron
    @netid = current_user.uid
    @patron = current_patron?(@netid)
  end

  def current_account
    if (@patron)
      logger.info("#{@patron}")
      @account = voyager_myaccount?(@patron)
    end
  end

  def account_client
    if (@patron)
      VoyagerAccountClient.new(@patron)
    end
  end

  def authenticate_patron patron
  end

  def construct_renew_request items
  end

  def construct_cancel_request requests
  end
end