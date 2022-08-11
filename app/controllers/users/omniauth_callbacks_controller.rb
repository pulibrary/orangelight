# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def cas
      @user = User.from_cas access_token_in_request_params

      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      if is_navigational_format?
        set_flash_message(:notice, :success, kind: 'from Princeton Central Authentication '\
                                                   'Service')
      end
    end

    def barcode
      if !patron_valid?
        flash_validation
        set_flash_message(:error, :failure,
                          reason: 'barcode or last name did not match active patron')
        redirect_to user_barcode_omniauth_authorize_path(origin: omniauth_origin)
      elsif netid_patron?(patron)
        flash[:error] = I18n.t('blacklight.login.barcode_netid')
        redirect_to user_barcode_omniauth_authorize_path(origin: omniauth_origin)
      else
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'with barcode') if is_navigational_format?
      end
    rescue Bibdata::PerSecondThresholdError
      set_flash_message(:error, :failure,
                        reason: 'the current request load is high')
      redirect_to user_barcode_omniauth_authorize_path(origin: omniauth_origin)
    end

    def alma
      if Alma::User.authenticate(user_id: ERB::Util.url_encode(alma_params[:username]), password: alma_params[:password])
        @user ||= User.from_alma(access_token_in_request_params)
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'with alma account') if is_navigational_format?
      else
        set_flash_message(:error, :failure,
          reason: 'username or password did not match an alma account')
        redirect_to user_barcode_omniauth_authorize_path(origin: omniauth_origin)
      end
    end

    private

      def barcode_user
        @user ||= User.from_barcode(barcode_token_in_request_params)
      end

      def patron
        @patron ||= Bibdata.get_patron(barcode_user)
      end

      def patron_valid?
        !patron.nil? && last_name_match?(@user.username, patron['last_name']) && @user.valid?
      end

      def omniauth_origin
        request.env['omniauth.origin']
      end

      def last_name_match?(username, last_name)
        !last_name.nil? && username.casecmp(last_name).zero?
      end

      def netid_patron?(patron)
        return false if patron['expire_date'].nil?
        !patron['netid'].nil? && Date.parse(patron['expire_date']) > Time.zone.today
      end

      def flash_validation
        flash[:barcode] = @user.errors[:uid] unless @user.errors[:uid].empty?
        flash[:last_name] = @user.errors[:username] unless @user.errors[:username].empty?
      end

      # Accesses the access token passed within the request headers
      # @return [OmniAuth::AuthHash,nil] the access token
      def access_token_in_request_params
        request.env['omniauth.auth']
      end

      # Accesses and cleans the access token passed within the request headers
      # This cleaning is for clients authenticating using patron barcodes
      # @return [OmniAuth::AuthHash,nil] the access token
      def barcode_token_in_request_params
        access_token = access_token_in_request_params
        access_token.uid = access_token.uid.gsub(/\s/, '') unless access_token.nil? || access_token.uid.blank?
        access_token
      end

      def alma_params
        params.permit(:username, :password)
      end
  end
end
