# frozen_string_literal: true
require 'rails_helper'

describe 'request', vcr: { cassette_name: 'bd_request_features', record: :none }, type: :feature do
  let(:direct_match) { '9913584543506421?mfhd=mfhd=22733836270006421' }
  let(:no_direct_match) { '99101599263506421' }
  let(:no_isbn) { '9925591603506421' }

  let(:user) { FactoryBot.create(:user) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { fixture('/bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { fixture('/bibdata_not_found_patron_response.json') }
  let(:bd_response) { fixture('/bd_response.json') }

  context 'a princeton netID user' do
    before do
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
      login_as user
    end

    # before(:each) do
    #   stub_request(:post, BorrowDirect::Defaults.api_base)
    #     .to_return(status: 200, body: bd_response, headers: {})
    # end

    describe 'When visiting a direct match item', js: true do
      xit "shows BD as the only option" do
        visit "/requests/#{direct_match}"
        wait_for_ajax
        expect(page).to have_select('requestable[][type]', selected: 'Borrow Direct (4 business days or less)')
      end
    end
  end
end
