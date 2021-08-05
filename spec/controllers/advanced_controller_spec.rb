# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvancedController do
  describe "#numismatics" do
    context "when requesting HTML for numismatics" do
      it "returns OK" do
        get :numismatics, params: { format: "html" }
        expect(response.status).to eq 200
      end
    end
    context "when requesting JSON for numismatics" do
      it "returns an error" do
        get :numismatics, params: { format: "json" }
        expect(response.status).to eq 400
      end
    end
  end
end
