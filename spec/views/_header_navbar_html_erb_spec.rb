require 'rails_helper'

describe '_header_navbar.html.erb' do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
    end
  end

  before do
    allow(view).to receive(:has_user_authentication_provider?).and_return(false)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    render partial: 'shared/header_navbar'
  end
  it 'links to Help' do
    expect(rendered).to have_xpath("//li/a[@href='/help']")
  end
end
