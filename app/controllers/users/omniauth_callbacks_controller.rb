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
      @user = User.from_barcode barcode_token_in_request_params
      patron = Bibdata.get_patron(@user.uid)
      valid_user = @user.valid?
      if patron == false || !last_name_match?(@user.username, patron['last_name']) || !valid_user
        flash_validation
        redirect_to user_barcode_omniauth_authorize_path(origin: request.env['omniauth.origin'])
        set_flash_message(:error, :failure,
                          reason: 'barcode or last name did not match active patron')
      elsif netid_patron?(patron)
        redirect_to user_barcode_omniauth_authorize_path(origin: request.env['omniauth.origin'])
        flash[:error] = I18n.t('blacklight.login.barcode_netid')
      else
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'with barcode') if is_navigational_format?
      end
    end

    private

      def last_name_match?(username, last_name)
        !last_name.nil? && username.casecmp(last_name).zero?
      end

      def netid_patron?(patron)
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
        unless access_token.nil? || access_token.uid.empty?
          access_token.uid = access_token.uid.gsub(/\s/, '')
        end
        access_token
      end
  end
end
