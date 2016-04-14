require "rails_helper"

RSpec.describe AccountController, type: :routing do
  describe "routing" do
    it "myaccount routes to #index controller" do
      expect(get: "/account").to route_to("account#index")
    end

    it "Renew Actions produce error when requested via get" do
      expect(get: "/account/renew").not_to be_routable
    end

    it "Renew Actions route to #renew when posted" do
      expect(post: "/account/renew").to route_to("account#renew")
    end

    it "Cancel Request Actions produce error when requested via get" do
      expect(get: "/account/cancel").not_to be_routable
    end

    it "Cancel Request Actions route to #cancel when posted" do
      expect(post: "/account/cancel").to route_to("account#cancel")
    end
  end
end
