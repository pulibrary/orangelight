require "rails_helper"

RSpec.describe AccountController, :type => :routing do
  describe "routing" do

    it "myaccount routes to #index controller" do
      expect(:get => "/account").to route_to("account#index")
    end

  end
end