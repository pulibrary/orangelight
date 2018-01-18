# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController, type: :routing do
  describe 'routing' do
    it 'catalog/oclc/123 routes to #oclc' do
      expect(get: '/catalog/oclc/123').to route_to('catalog#oclc', id: '123')
    end
    it 'catalog/lccn/34 routes to #lccn' do
      expect(get: '/catalog/lccn/34').to route_to('catalog#lccn', id: '34')
    end
    it 'catalog/issn/45 routes to #issn' do
      expect(get: '/catalog/issn/45').to route_to('catalog#issn', id: '45')
    end
    it 'catalog/isbn/99 routes to #isbn' do
      expect(get: '/catalog/isbn/99').to route_to('catalog#isbn', id: '99')
    end
    it 'catalog/99/staff_view routes to #librarian_view' do
      expect(get: '/catalog/99/staff_view').to route_to('catalog#librarian_view', id: '99')
    end
  end
end
