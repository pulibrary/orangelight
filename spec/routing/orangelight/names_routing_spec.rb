require "rails_helper"

RSpec.describe Orangelight::BrowsablesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/browse/names").to route_to("orangelight/browsables#index", model: Orangelight::Name)
    end

    it "routes to #show" do
      expect(:get => "/browse/names/1").to route_to("orangelight/browsables#show", :id => "1", model: Orangelight::Name)
    end


  end
end
