# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "emailing bookmarks" do
  let(:user) { FactoryBot.create(:user) }
  before do
    login_as(user)
  end

  it 'sets a flash message on success' do
    pending("Getting flash messages to persist only just long enough, but not too long")
    # params = { subject: 'PU+Library+Catalog+Shared+Record(s)', id: '99125535710106421', message: '', to: 'example@test.com' }
    # post '/bookmarks/email', params: params

    post '/bookmarks/email', xhr: true, params: { id: '99125535710106421', to: 'test_email@projectblacklight.org' }
    expect(request).to render_template 'email_success'
    expect(request.flash[:success]).to eq "Email Sent"

    # expect(response).to redirect_to('/bookmarks')
    expect(flash.keys).not_to include('error')
    expect(flash[:success]).to eq("Email Sent")
    expect(flash.instance_variable_get("@discard")).to be_empty

    # follow_redirect!
    # The flash message should only be good for this action
    # expect(flash.instance_variable_get("@discard").first).to eq("success")

    get '/bookmarks'
    expect(flash).to be_empty
  end
end
