# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "FeaturesController" do
  describe "features page" do
    context "when logged in as an admin" do
      let(:user) { FactoryBot.create(:user) }
      before do
        login_as(user)
      end
      around do |example|
        cached_admin_netids = ENV['ORANGELIGHT_ADMIN_NETIDS'] || ''
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids + " #{user.uid}"
        example.run
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids
      end
      it "allows the user to see the admin page" do
        get "/features"
        expect(response).to be_successful
        expect(response.body).to have_content("Orangelight Features")
        expect(flash[:alert]).to be nil
      end
    end
    context "when logged in as a regular user" do
      let(:user) { FactoryBot.create(:user) }
      before do
        login_as(user)
      end

      it "does not allow the user to see the admin page" do
        get "/features"
        expect(response).to be_forbidden
      end
    end
    context "when not logged in" do
      let(:user) { FactoryBot.create(:unauthenticated_patron) }

      it "redirects to the login page" do
        get "/features"
        expect(response).to redirect_to("http://www.example.com/users/sign_in")
      end
    end
  end
end
