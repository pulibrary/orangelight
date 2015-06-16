# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Blacklight.secret_key = '97ccd2bbcdf62fd419cc257f3aad8be90f41fcae39cb710847d6191723a354bd033aad2d4d034cae8166697ea432853491ee1e9688d33b4659c26ce4bf4c647b'
require 'faraday'

module Blacklight::Solr::Document::Marc
  def marc_record_from_marcxml
    id = fetch(_marc_source_field)
    record = Faraday.get("http://bibdata.princeton.edu/bibliographic/#{id}").body
    MARC::XMLReader.new(StringIO.new( record )).to_a.first
  end
end