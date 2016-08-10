module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def cas
      @user = User.from_omniauth(request.env['omniauth.auth'])

      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: 'CAS') if is_navigational_format?
    end
  end
end
