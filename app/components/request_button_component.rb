# frozen_string_literal: true

# ViewComponent that displays a request button on the show page
class RequestButtonComponent < ViewComponent::Base
  def initialize(location:, doc_id:, holding_id: nil, force_aeon: false)
    @location = location
    @doc_id = doc_id
    @holding_id = holding_id
    @force_aeon = force_aeon
  end

  def label
    return 'Reading Room Request' if aeon?
    'Request'
  end

  def tooltip
    return 'Request to view in Reading Room' if aeon?
    'View Options to Request copies from this Location'
  end

  def url
    query = { mfhd: @holding_id, aeon: aeon?.to_s }.compact.to_query
    URI::HTTP.build(path: "/requests/#{@doc_id}", query:).request_uri
  end

  private

    def aeon?
      @aeon ||= @force_aeon || @location&.dig(:aeon_location)
    end
end
