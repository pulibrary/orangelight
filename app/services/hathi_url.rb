# frozen_string_literal: true
class HathiUrl
  attr_reader :url

  def initialize(oclc_id:, isbn:, lccn:)
    @url = build_hathi_url(key: 'oclc', id: oclc_id) ||
           build_hathi_url(key: 'isbn', id: isbn) ||
           build_hathi_url(key: 'lccn', id: lccn)
  end

  private

    def build_hathi_url(key:, id:)
      return if id.blank?
      uri = URI("https://catalog.hathitrust.org/api/volumes/brief/#{key}/#{id}.json")
      json_data = Net::HTTP.get(uri)
      hathi_data = JSON.parse(json_data)
      hathi_url(hathi_data['items'].first['htid']) if hathi_data['items'].count.positive?
    end

    def hathi_url(htid)
      "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3D#{htid}"
    end
end
