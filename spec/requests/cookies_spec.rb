# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'Cookies' do
  it 'sets HttpOnly' do
    get '/'
    expect(response.headers['set-cookie'].first).to include('httponly')
  end
end
