require "rails_helper"

RSpec.describe Orangelight::BrowsablesController, type: :routing do
  describe "routing" do
    it "browse/names routes to #index" do
      expect(get: "/browse/names").to route_to("orangelight/browsables#index", model: Orangelight::Name)
    end

    it "browse/names/1 routes to #show" do
      expect(get: "/browse/names/1").to route_to("orangelight/browsables#show", id: "1", model: Orangelight::Name)
    end

    it "browse/subjects routes to #index" do
      expect(get: "/browse/subjects").to route_to("orangelight/browsables#index", model: Orangelight::Subject)
    end

    it "browse/subjects/1 routes to #show" do
      expect(get: "/browse/subjects/1").to route_to("orangelight/browsables#show", id: "1", model: Orangelight::Subject)
    end

    it "browse/call_numbers routes to #index" do
      expect(get: "/browse/call_numbers").to route_to("orangelight/browsables#index", model: Orangelight::CallNumber)
    end

    it "browse routes to #browse" do
      expect(get: "/browse").to route_to("orangelight/browsables#browse")
    end
  end
end
