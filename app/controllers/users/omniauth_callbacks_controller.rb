require './lib/orangelight/bibdata.rb'

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def cas
      @user = User.from_cas(request.env['omniauth.auth'])

      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: 'from Princeton Central Authentication '\
                                                 'Service') if is_navigational_format?
    end

    def barcode
      @user = User.from_barcode(request.env['omniauth.auth'])
      patron = Bibdata.get_patron(@user.uid)
      if patron == false || !last_name_match?(@user.username, patron['last_name'])
        redirect_to new_user_session_path
        set_flash_message(:error, :failure,
                          reason: 'barcode or last name did not match active patron')
      elsif redirect_to_cas?(patron)
        redirect_to user_cas_omniauth_authorize_path
      else
        @user.save
        sign_in_and_redirect @user, event: :authentication # this will throw if @user not activated
        set_flash_message(:notice, :success, kind: 'via barcode') if is_navigational_format?
      end
    end

    private

      def last_name_match?(username, last_name)
        !last_name.nil? && username.casecmp(last_name).zero?
      end

      def redirect_to_cas?(patron)
        !patron['netid'].nil? && Date.parse(patron['expire_date']) > Time.zone.today
      end
  end
end
