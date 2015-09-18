require 'rails_helper'

# The ip restriction is on the ApplicationController, but unlike the CatalogController, it doesn't have any routes
RSpec.describe CatalogController, :type => :controller do

  it "authorized ips can access application" do
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
    allow_any_instance_of(ApplicationController).to receive(:load_ip_whitelist).and_return(['192.168.0.1'])    
    get :index
    expect(response).to have_http_status(200)
  end

  it "all users can access application when ip whitelist is blank" do
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
    allow_any_instance_of(ApplicationController).to receive(:load_ip_whitelist).and_return(nil)    
    get :index
    expect(response).to have_http_status(200)
  end

  it "unuathorized users are redirected to library mainpage" do
    allow_any_instance_of(ApplicationController).to receive(:load_ip_whitelist).and_return(['192.168.0.1'])    
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('127.0.0.1')
    get :index
    expect(response).to have_http_status(302)
  end

end
