# frozen_string_literal: true

require 'rails_helper'

describe 'citation' do
  it 'will render successfully even if there is not a subfield a' do
    stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/9979948663506421")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Faraday v0.17.4'
        }
      )
      .to_return(status: 200, body: "", headers: {})

    visit '/catalog/9979948663506421/citation'
    expect(current_url).to include '/catalog/9979948663506421/citation'
    expect(page.status_code).to eq 200
  end
end
