# frozen_string_literal: true

# ViewComponent that displays a request button on the show page
class RequestButtonComponent < ViewComponent::Base
  def initialize(location:, doc_id:, holding: nil, holding_id: nil)
    @location = location
    @doc_id = doc_id
    @holding = holding
    @holding_id = holding_id
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
      @aeon ||= (@location&.dig(:aeon_location) || scsb_supervised_items?)
    end

    def scsb_supervised_items?
      return false unless @holding
      return false unless @holding['items']
      @holding['items'].all? { |item| item['use_statement'] == 'Supervised Use' }
    end
end
