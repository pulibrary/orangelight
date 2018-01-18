# frozen_string_literal: true

require 'rails_helper'

describe FeedbackController, type: :routing do
  describe 'routing' do
    it '/feedback routes to a new form' do
      expect(get: '/feedback').to route_to('feedback#new')
    end

    it '/feedback posts to create' do
      expect(post: '/feedback').to route_to('feedback#create')
    end
  end
end
