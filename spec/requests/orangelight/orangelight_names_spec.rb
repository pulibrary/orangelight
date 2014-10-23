require 'rails_helper'

RSpec.describe "Orangelight::Names", :type => :request do
  describe "GET /orangelight_names" do
    it "works! (now write some real specs)" do
      get browse_names_path
      expect(response.status).to be(200)
    end
  end
end
