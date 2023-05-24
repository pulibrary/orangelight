# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  let(:user) { FactoryBot.create(:valid_princeton_patron) }
  describe "#after_sign_in_path_for" do
    context "as a logged in user" do
      before { login_as(user) }

      context 'url only' do
        it 'redirects to alma' do
          get "/users/sign_in?origin=%2Fredirect-to-alma"
          expect(response).to redirect_to("/redirect-to-alma")
        end
      end
      context 'only an origin is set' do
        it 'redirects to alma' do
          params = { origin: '/redirect-to-alma' }
          get '/users/sign_in', params: params
          expect(response).to redirect_to("/redirect-to-alma")
        end
        it 'redirects to bookmarks' do
          params = { origin: '/bookmarks' }
          get '/users/sign_in', params: params
          expect(response).to redirect_to('/bookmarks')
        end
      end

      context 'only a referrer is set' do
        it 'redirects to the referrer' do
          headers = { 'HTTP_REFERER' => '/bookmarks' }
          get '/users/sign_in', headers: headers
          expect(response).to redirect_to('/bookmarks')
        end
        it 'redirects to the origin from the referrer' do
          headers = { 'HTTP_REFERER' => '/users/sign_in/?origin=%2Fbookmarks' }
          get '/users/sign_in', headers: headers
          expect(response).to redirect_to('/bookmarks')
        end
      end

      context 'both an origin and a referrer are set' do
        it 'redirects to alma' do
          params = { origin: '/redirect-to-alma' }
          headers = { 'HTTP_REFERER' => '/' }
          get '/users/sign_in', params: params, headers: headers
          expect(response).to redirect_to('/redirect-to-alma')
        end
      end

      context "with omniauth origin" do
        around do |example|
          Rails.application.env_config["omniauth.origin"] = '/bookmarks'
          example.run
          Rails.application.env_config.except!("omniauth.origin")
        end

        it "sends the user back to the omniauth origin" do
          get '/users/sign_in/'
          expect(response).to redirect_to('/bookmarks')
        end
      end
      # rubocop:disable RSpec/AnyInstance
      context 'only with devise stored_location_for' do
        before do
          allow_any_instance_of(Devise::Controllers::StoreLocation).to receive(:stored_location_for)
            .and_return('/requests/SCSB-2143785')
        end
        context 'with a CAS user' do
          let(:user) { FactoryBot.create(:valid_princeton_patron) }

          it 'redirects the user to the stored resource' do
            get '/users/sign_in'
            expect(response).to redirect_to('/requests/SCSB-2143785')
          end
        end
        context 'with an Alma user' do
          let(:user) { FactoryBot.create(:valid_alma_patron) }

          it 'redirects the user to the stored resource' do
            get '/users/sign_in'
            expect(response).to redirect_to('/requests/SCSB-2143785')
          end
        end
      end
      # rubocop:enable RSpec/AnyInstance
    end

    context "as an unauthenticated user" do
      it 'does not redirect the user' do
        get "/users/sign_in?origin=%2Fredirect-to-alma"
        expect(response).to be_successful
      end
    end
  end

  describe 'profiling authentication' do
    let(:user) { FactoryBot.create(:user) }
    before do
      login_as(user)
      allow(ApplicationController).to receive(:current_user).and_return(user)
    end

    context 'as a non-admin user' do
      it 'does not authorize the user' do
        allow(Rack::MiniProfiler).to receive(:authorize_request)
        get '/'
        expect(Rack::MiniProfiler).not_to have_received(:authorize_request)
      end
    end
    context 'as an admin user' do
      around do |example|
        cached_admin_netids = ENV['ORANGELIGHT_ADMIN_NETIDS'] || ''
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids + " #{user.uid}"
        example.run
        ENV['ORANGELIGHT_ADMIN_NETIDS'] = cached_admin_netids
      end

      it 'authorizes the user' do
        allow(Rack::MiniProfiler).to receive(:authorize_request)
        get '/'
        expect(Rack::MiniProfiler).to have_received(:authorize_request)
      end
    end
  end
end
