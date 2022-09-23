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

    def alma
      if Alma::User.authenticate(user_id: ERB::Util.url_encode(alma_params[:username]), password: alma_params[:password])
        @user ||= User.from_alma(access_token_in_request_params)
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'with alma account') if is_navigational_format?
      else
        set_flash_message(:error, :failure,
          reason: 'username or password did not match an alma account')
        redirect_to user_alma_omniauth_authorize_path(origin: omniauth_origin)
      end
    end

    private

      def omniauth_origin
        request.env['omniauth.origin']
      end

      # Accesses the access token passed within the request headers
      # @return [OmniAuth::AuthHash,nil] the access token
      def access_token_in_request_params
        request.env['omniauth.auth']
      end

      def alma_params
        params.permit(:username, :password)
      end
  end
end
