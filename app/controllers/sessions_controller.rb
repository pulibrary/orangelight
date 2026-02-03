# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  # DELETE /resource/sign_out
  def destroy
    @provider = current_user.provider
    super
  end

  private

    def respond_to_on_destroy(non_navigational_status: :no_content)
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.all { head non_navigational_status }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(@provider), allow_other_host: true }
      end
    end
end
