# frozen_string_literal: true

# ViewComponent that displays a request button on the show page
# :reek:TooManyInstanceVariables
class RequestButtonComponent < ViewComponent::Base
  def initialize(location:, doc_id:, holding: nil, holding_id: nil, open_holdings: nil)
    @location = location
    @doc_id = doc_id
    @holding = holding
    @holding_id = holding_id
    @open_holdings = open_holdings
  end

  def label
    return 'Reading Room Request' if aeon?
    'Request'
  end

  def url
    query = { mfhd: @holding_id, aeon: aeon?.to_s, open_holdings: }.compact.to_query
    URI::HTTP.build(path: "/requests/#{@doc_id}", query:).request_uri
  end

  private

    attr_reader :open_holdings

    def aeon?
      @aeon ||= (@location&.dig(:aeon_location) || scsb_supervised_items?)
    end

    def scsb_supervised_items?
      return false unless @holding
      return false unless @holding['items']
      @holding['items'].all? { |item| item['use_statement']&.casecmp('supervised use')&.zero? }
    end
end
