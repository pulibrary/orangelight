require 'rails_helper'

describe RequestController, type: :routing do
  describe 'routing' do
    it '/request/123456 routes to help page' do
      expect(get: '/request/123456').to route_to('request#show', id: '123456')
    end
  end
end
