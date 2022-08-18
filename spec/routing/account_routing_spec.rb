# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController, type: :routing do
  describe 'routing' do
    it 'myaccount routes to #index controller' do
      expect(get: '/account').to route_to('account#index')
    end

    it 'Renew Actions produce error when requested via get' do
      expect(get: '/account/renew').not_to be_routable
    end

    it 'Cancel Request Actions produce error when requested via get' do
      expect(get: '/account/cancel').not_to be_routable
    end

    context 'with old borrow direct provider' do
      before do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:reshare_for_borrow_direct, false)
      end
      it 'Links to borrow direct route to #borrow_direct_redirect' do
        expect(get: '/borrow-direct').to route_to('account#borrow_direct_redirect')
      end
    end
  end
end
