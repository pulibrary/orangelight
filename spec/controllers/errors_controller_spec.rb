# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController do
  it "returns 404 for not found errors" do
    get :missing
    expect(response.status).to eq 404
  end
  it "returns 500 for general errors" do
    get :error
    expect(response.status).to eq 500
  end
end
