# frozen_string_literal: true

bd_base_url = "#{ENV['APPLICATION_HOST_PROTOCOL']}://#{ENV['APPLICATION_HOST']}" || 'http://localhost:3000'
BorrowDirect::Defaults.html_base_url = "#{bd_base_url}/borrow-direct"

# Set Relais base URL as a constant for internal use
RELAIS_BASE = 'https://bd.relaisd2d.com/?'
# Set a default BD LibrarySymbol for your library
BorrowDirect::Defaults.library_symbol = 'PRINCETON'

BorrowDirect::Defaults.api_key = ENV['BD_AUTH_KEY']

# BorrowDirect::Defaults.api_base = 'https://bdtest.relais-host.com'
BorrowDirect::Defaults.api_base = BorrowDirect::Defaults::PRODUCTION_API_BASE
BorrowDirect::Defaults.find_item_patron_barcode = ENV['BD_FIND_BARCODE']
BorrowDirect::Defaults.timeout = 30
