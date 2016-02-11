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
    else
      flash.now[:error] = I18n.t('blacklight.account.inaccessible')
    end
  end

  def account_client
    if (@patron)
      VoyagerAccountClient.new(@patron)
    end
  end

  private
  
  def current_patron? netid
    return false unless netid
    begin 
      patron_record = Faraday.get "#{ENV['bibdata_base']}/patron/#{netid}"
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to connect to #{ENV['bibdata_base']}")
      return false
    end

    if patron_record.status == 403
      logger.info("403 Not Authorized to Connect to Patron Data Service at #{ENV['bibdata_base']}/patron/#{netid}")
      return false 
    end
    if patron_record.status == 404
      logger.info("404 Patron #{netid} cannot be found in the Patron Data Service.")
      return false 
    end
    patron = JSON.parse(patron_record.body).with_indifferent_access
    logger.info("#{patron.to_hash}")
    patron
  end

  def voyager_myaccount? patron
    begin
      voyager_account = Faraday.get "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{patron[:patron_id]}&patronHomeUbId=1@DB"
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    if voyager_account.status == 403
      logger.info("403 Not Authorized to Connect to Voyager My Account Service.")
      return false
    end
    if voyager_account.status == 404
      logger.info("404 Patron id #{patron[:patron_id]} cannot be found in the Voyager My Account Service.")
      return false 
    end
    account = VoyagerAccount.new(voyager_account.body)
    logger.info("#{account.source_doc}")
    account
  end

  def authenticate_patron patron
  end

  def construct_renew_request items
  end

  def construct_cancel_request requests
  end
end