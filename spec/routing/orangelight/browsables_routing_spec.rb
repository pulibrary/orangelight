require 'rails_helper'

RSpec.describe Orangelight::BrowsablesController, type: :routing do
  describe 'routing' do
    it 'browse/names routes to #index' do
      expect(get: '/browse/names').to route_to('orangelight/browsables#index', model: Orangelight::Name)
    end

    it 'browse/name_titles routes to #index' do
      expect(get: '/browse/name_titles').to route_to('orangelight/browsables#index', model: Orangelight::NameTitle)
    end

    it 'browse/subjects routes to #index' do
      expect(get: '/browse/subjects').to route_to('orangelight/browsables#index', model: Orangelight::Subject)
    end

    it 'browse/call_numbers routes to #index' do
      expect(get: '/browse/call_numbers').to route_to('orangelight/browsables#index', model: Orangelight::CallNumber)
    end

    it 'browse routes to #browse' do
      expect(get: '/browse').to route_to('orangelight/browsables#browse')
    end
  end
end
