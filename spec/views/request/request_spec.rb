require 'rails_helper'

describe "Request Page", :type => :feature do

  it "Produces a page that contains a link to the request system" do
    visit('/request/7916044')
    expect(page).to have_xpath('.//a[@href="https://library.princeton.edu/requests/7916044"]')

  end
end