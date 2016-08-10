class SessionsController < Devise::SessionsController
  # DELETE /resource/sign_out
  def destroy
    @provider = current_user.provider
    super
  end

  private

    def respond_to_on_destroy
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(@provider) }
      end
    end
end
