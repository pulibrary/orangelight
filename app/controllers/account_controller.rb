# frozen_string_literal: true

require './lib/orangelight/voyager_patron_client.rb'
require './lib/orangelight/voyager_account.rb'
require './lib/orangelight/illiad_patron_client.rb'
require './lib/orangelight/illiad_account.rb'

class AccountController < ApplicationController
  include ApplicationHelper
  include AccountHelper

  before_action :require_user_authentication_provider
  before_action :verify_user, except: [:borrow_direct_redirect]

  def index
    if Orangelight.read_only_mode
      msg = "Account page is disabled. #{Orangelight.read_only_message}"
      redirect_to root_path, flash: { notice: msg }
    else
      set_patron
      current_account
    end
  end

  def renew
    set_patron
    @account = account_client.renewal_request(params[:renew_items]) unless params[:renew_items].nil?

    respond_to do |format|
      if params[:renew_items].nil?
        format.js { flash.now[:error] = I18n.t('blacklight.account.renew_no_items') }
      elsif @account
        if @account.failed_renewals?
          format.js { flash.now[:alert] = I18n.t('blacklight.account.renew_partial_fail') }
        else
          format.js { flash.now[:success] = I18n.t('blacklight.account.renew_success') }
        end
      else
        format.js { flash.now[:error] = I18n.t('blacklight.account.renew_fail') }
      end
    end
  end

  def borrow_direct_redirect
    cas_user
  end

  # The action has to call 'current_account' this so you "know" have many active requests
  # there were previously attached to account prior to calling the cancel_active_requests
  # for the items whose cancellation was requested. Unlike the Renew option successfully
  # cancelled items just drop off the list of outstanding requests in the response back
  # from Voyager's CancelService web service. The method cancel_success compares the response
  # to current_account to confirm that the cancellation did succeed.
  def cancel
    set_patron
    unless params[:cancel_requests].nil?
      current_account
      initial_hold_requests = @account.outstanding_hold_requests
      @account = account_client.cancel_active_requests(params[:cancel_requests])
    end

    respond_to do |format|
      if params[:cancel_requests].nil?
        format.js { flash.now[:error] = I18n.t('blacklight.account.cancel_no_items') }
      elsif cancel_success(initial_hold_requests, @account, params[:cancel_requests])
        format.js { flash.now[:success] = I18n.t('blacklight.account.cancel_success') }
      else
        format.js { flash.now[:error] = I18n.t('blacklight.account.cancel_fail') }
      end
    end
  end

  def cancel_ill_requests
    set_patron
    unless params[:cancel_requests].nil?
      current_account
      response = IlliadPatronClient.new(@patron).cancel_ill_requests(params[:cancel_requests])
    end
    illiad_patron_client(@patron)
    respond_to do |format|
      if params[:cancel_requests].nil?
        format.js { flash.now[:error] = I18n.t('blacklight.account.cancel_no_items') }
      elsif cancel_ill_success(response)
        format.js { flash.now[:success] = I18n.t('blacklight.account.cancel_success') }
      else
        format.js { flash.now[:error] = I18n.t('blacklight.account.cancel_fail') }
      end
    end
  end

  protected

    def verify_user
      unless current_user
        flash[:error] = I18n.t('blacklight.saved_searches.need_login') &&
                        raise(Blacklight::Exceptions::AccessDenied)
      end
    end

    def cas_user
      if current_user
        set_patron
        if @patron && @patron[:barcode] && (current_user.provider == 'cas' && (@patron[:campus_authorized] || @patron[:campus_authorized_category] == 'trained'))
          redirect_to borrow_direct_url(@patron[:barcode])
        else
          flash[:error] = I18n.t('blacklight.account.borrow_direct_ineligible')
          redirect_to root_url
        end
      else
        redirect_to user_cas_omniauth_authorize_path(origin: url_for(params.permit!))
      end
    end

    ## For local dev purposes hardcode a net id string in place of current_user.uid
    ## in this method. Hacky, but convienent to see what "real" data looks like for
    ## edge case patrons.
    def set_patron
      @netid = current_user.uid
      @patron = current_patron(@netid)
      illiad_patron_client(@patron)
    end

    def current_account
      if @patron
        @account = voyager_account(@patron)
      else
        flash.now[:error] = I18n.t('blacklight.account.inaccessible')
      end
    end

    def account_client
      VoyagerPatronClient.new(@patron) if @patron
    end

    def illiad_patron_client(patron)
      @illiad_transactions = []
      return unless patron && current_user.provider == 'cas'

      @illiad_account = IlliadAccount.new(patron)
      return unless @illiad_account.verify_user

      @illiad_transactions = IlliadPatronClient.new(patron).outstanding_ill_requests
    end

    def cancel_success(total_original_items, updated_account, number_of_cancelled_items)
      return false if updated_account.nil?
      total_updated_items = updated_account.outstanding_hold_requests
      deleted_requests = total_original_items - total_updated_items
      return true if number_of_cancelled_items.size == deleted_requests
      false
    end

    def cancel_ill_success(response)
      bodies = response.map { |rep| JSON.parse(rep.body) }
      bodies.reject { |body| body['TransactionStatus'] =~ /^Cancelled/ }.empty?
    end

  private

    def current_patron(netid)
      Bibdata.get_patron(netid)
    end

    def borrow_direct_url(barcode)
      url = if params[:q]
              BorrowDirect::GenerateQuery.new(RELAIS_BASE).query_url_with(keyword: params[:q])
            elsif params[:query] # code in umlaut borrow direct gem requires 'query' as a param
              BorrowDirect::GenerateQuery.new(RELAIS_BASE).query_url_with(params[:query])
            else
              RELAIS_BASE
            end
      %(#{url}&LS=#{BorrowDirect::Defaults.library_symbol}&PI=#{barcode})
    end

    def voyager_account(patron)
      begin
        response = Faraday.get "#{ENV['voyager_api_base']}/vxws/MyAccountService?"\
                                      "patronId=#{patron[:patron_id]}&patronHomeUbId=1@DB"
      rescue Faraday::Error::ConnectionFailed
        logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
        return false
      end
      if response.status == 403
        logger.info('403 Not Authorized to Connect to Voyager My Account Service.')
        return false
      end
      if response.status == 404
        logger.info("404 Patron id #{patron[:patron_id]} cannot be "\
                    'found in the Voyager My Account Service.')
        return false
      end
      VoyagerAccount.new(response.body)
    end
end
