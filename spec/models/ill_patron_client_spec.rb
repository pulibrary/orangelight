# frozen_string_literal: true

# require 'rails_helper'
#
# require './lib/orangelight/ill_patron_client.rb'
# require './lib/orangelight/ill_account.rb'
#
# RSpec.describe ILLPatronClient do
#   context 'A valid Princeton User' do
#     sample_patron = { 'barcode' => '2232323232323',
#                       'last_name' => 'smith',
#                       'patron_id' => '777777' }
#     subject(:client) { described_class.new(sample_patron) }
#
#     let(:valid_cancel_request_uri) { "#{ENV['voyager_api_base']}/vxws/CancelService" }
#
#     describe '#outstanding_ill_requests' do
#       it 'Returns a successful http response' do
#         expect(client.myaccount).to be_a(Faraday::Response)
#         expect(client.myaccount.status).to eq(200)
#       end
#     end
#   end
# end
