# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'Cookies' do
  it 'sets SameSite=strict' do
    get '/'
    expect(response.headers['Set-Cookie']).to include('SameSite=Strict')
  end
  it 'sets HttpOnly' do
    get '/'
    expect(response.headers['Set-Cookie']).to include('HttpOnly')
  end
end
