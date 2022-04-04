# frozen_string_literal: true
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.ignore_hosts 'webvoyage.princeton.edu', 'https://uat-recap.htcinc.com.htcinc.com', 'scsb.recaplib.org', BorrowDirect::Defaults.api_base, 'chromedriver.storage.googleapis.com'
  c.ignore_request do |request|
    request.uri.include? 'patron'
  end
end
