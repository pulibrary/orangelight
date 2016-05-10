require 'rails_helper'

describe HighVoltage::PagesController, type: :routing do
  describe 'routing' do
    it '/help routes to help page' do
      expect(get: '/help').to route_to('high_voltage/pages#show', id: 'help')
    end
  end
end
