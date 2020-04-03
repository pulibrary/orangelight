# frozen_string_literal: true
class HathiUrl
  attr_reader :url, :maximum_retries, :sleep_duration

  # rubocop:disable Lint/UnusedMethodArgument
  def initialize(oclc_id:, isbn: nil, lccn: nil, maximum_retries: 2, sleep_duration: 10)
    @retry_count = 0
    @maximum_retries = maximum_retries
    @sleep_duration = sleep_duration
    @url = build_hathi_url(key: 'oclc', id: oclc_id)
    # only match on oclc for the moment
    # @url = build_hathi_url(key: 'oclc', id: oclc_id) ||
    #        build_hathi_url(key: 'isbn', id: isbn) ||
    #        build_hathi_url(key: 'lccn', id: lccn)
  end
  # rubocop:enable Lint/UnusedMethodArgument

  private

    def build_hathi_url(key:, id:)
      return if id.blank?
      json_data = Net::HTTP.get(hathi_api_url(key: key, id: id))
      hathi_data = JSON.parse(json_data)
      hathi_url(hathi_data['items'].first['htid']) if hathi_data['items'].count.positive?
    rescue JSON::ParserError => e
      Rails.logger.warn(e.message)
      @retry_count += 1
      if @retry_count <= maximum_retries
        sleep sleep_duration
        retry
      else
        Rails.logger.warn("Got #{maximum_retries} Json Parse errors service replies with#{json_data}")
        nil
      end
    end

    def hathi_api_url(key:, id:)
      URI("https://catalog.hathitrust.org/api/volumes/brief/#{key}/#{id}.json")
    end

    def hathi_url(htid)
      "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3D#{htid}"
    end
end
