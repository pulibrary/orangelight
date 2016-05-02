require './lib/orangelight/voyager_patron_client.rb'
require './lib/orangelight/voyager_account.rb'

class AccountController < ApplicationController
  include ApplicationHelper
  include AccountHelper

  before_filter :require_user_authentication_provider
  before_filter :verify_user

  def index
    set_patron
    current_account
  end

  def renew
    set_patron
    unless params[:renew_items].nil?
      @account = account_client.renewal_request(params[:renew_items])
    end

    respond_to do |format|
      if params[:renew_items].nil?
        format.js { flash.now[:notice] =  I18n.t('blacklight.account.renew_no_items') }
      elsif !@account.nil?
        if @account.failed_renewals?
          format.js { flash.now[:alert] =  I18n.t('blacklight.account.renew_partial_fail') }
        else
          format.js { flash.now[:notice] =  I18n.t('blacklight.account.renew_success') }
        end
      else
        format.js { flash.now[:error] = I18n.t('blacklight.account.renew_fail') }
      end
    end
  end

  ## The action has to call 'current_account' this so you "know" have many active requests there were previously attached
  ## to account prior to calling the cancel_active_requests for the items whose
  ## cancellation was requested. Unlike the Renew option successfully cancelled items just
  ## drop off the list of outstanding requests in the response back from Voyager's CancelService
  ## web service. The method cancel_success compares the response to current_account to confirm
  ## that the cancellation did succeed.
  def cancel
    set_patron
    unless params[:cancel_requests].nil?
      current_account
      initial_hold_requests = @account.outstanding_hold_requests
      @account = account_client.cancel_active_requests(params[:cancel_requests])
    end

    respond_to do |format|
      if params[:cancel_requests].nil?
        format.js { flash.now[:notice] =  I18n.t('blacklight.account.cancel_no_items') }
      elsif cancel_success(initial_hold_requests, @account, params[:cancel_requests])
        format.js { flash.now[:notice] =  I18n.t('blacklight.account.cancel_success') }
      else
        format.js { flash.now[:error] = I18n.t('blacklight.account.cancel_fail') }
      end
    end
  end

  protected
  def verify_user
    flash[:notice] = I18n.t('blacklight.saved_searches.need_login') and raise Blacklight::Exceptions::AccessDenied unless current_user
  end

  ## For local dev purposes hardcode a net id string in place of current_user.uid
  ## in this method. Hacky, but convienent to see what "real" data looks like for
  ## edge case patrons.
  def set_patron
    @netid = current_user.uid
    @patron = current_patron?(@netid)
  end

  def current_account
    if (@patron)
      @account = voyager_account?(@patron)
    else
      flash.now[:error] = I18n.t('blacklight.account.inaccessible')
    end
  end

  def account_client
    if (@patron)
      VoyagerPatronClient.new(@patron)
    end
  end

  def cancel_success(total_original_items, updated_account, number_of_cancelled_items)
    return false if updated_account.nil?
    total_updated_items = updated_account.outstanding_hold_requests
    deleted_requests = total_original_items - total_updated_items
    if number_of_cancelled_items.size == deleted_requests
      return true
    else
      return false
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
    if patron_record.status == 500
      logger.info("Error Patron Data Service.")
      return false
    end
    patron = JSON.parse(patron_record.body).with_indifferent_access
    logger.info("#{patron.to_hash}")
    patron
  end

  def voyager_account? patron
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
    account
  end

end
