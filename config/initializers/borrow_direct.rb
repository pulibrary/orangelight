BorrowDirect::Defaults.html_base_url = 'https://borrow-direct.relaisd2d.com/service-proxy/?command=mkauth'

# Set a default BD LibrarySymbol for your library
BorrowDirect::Defaults.library_symbol = 'PRINCETON'

BorrowDirect::Defaults.api_key = ENV['BD_AUTH_KEY']

BorrowDirect::Defaults.api_base = BorrowDirect::Defaults::PRODUCTION_API_BASE
