BorrowDirect::Defaults.html_base_url = 'https://pulsearch.princeton.edu/borrow-direct'

# Set Relais base URL as a constant for internal use
RELAIS_BASE = 'https://borrow-direct.relaisd2d.com/service-proxy/?command=mkauth'
# Set a default BD LibrarySymbol for your library
BorrowDirect::Defaults.library_symbol = 'PRINCETON'

BorrowDirect::Defaults.api_key = ENV['BD_AUTH_KEY']

BorrowDirect::Defaults.api_base = 'https://bdtest.relais-host.com'
# BorrowDirect::Defaults.api_base = BorrowDirect::Defaults::PRODUCTION_API_BASE
BorrowDirect::Defaults.find_item_patron_barcode = ENV['BD_FIND_BARCODE']
BorrowDirect::Defaults.timeout = 60
