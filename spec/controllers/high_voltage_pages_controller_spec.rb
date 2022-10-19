# frozen_string_literal: true

require 'rails_helper'

describe HighVoltage::PagesController, type: :controller do
  context "on GET to /help" do
    before do
      get :show, params: { id: "help" }
    end
    it 'succeeds' do
      expect(response).to have_http_status(200)
    end
    it { is_expected.to render_template("help") }
  end
end
