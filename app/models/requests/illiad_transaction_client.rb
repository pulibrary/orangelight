# frozen_string_literal: true

# require 'faraday'
# require 'faraday-cookie_jar'

module Requests
  class IlliadTransactionClient < IlliadClient
    attr_reader :patron, :note, :illiad_transaction_status, :attributes

    def initialize(patron:, metadata_mapper:)
      super()
      @patron = patron
      @note = metadata_mapper.note
      @attributes = metadata_mapper.attributes
    end

    def create_request
      patron_client = Requests::IlliadPatron.new(patron)
      illiad_patron = patron_client.illiad_patron
      illiad_patron = patron_client.create_illiad_patron if illiad_patron.blank?
      return nil if illiad_patron.blank?
      return "DISAVOWED" if disavowed_illiad_patron?(illiad_patron)
      Requests::RequestMailer.send("invalid_illiad_patron_email", patron_client.attributes, attributes).deliver_now unless validate_illiad_patron(illiad_patron)
      transaction = post_json_response(url: 'ILLiadWebPlatform/transaction', body: attributes.to_json)
      post_json_response(url: "ILLiadWebPlatform/transaction/#{transaction['TransactionNumber']}/notes", body: "{ \"Note\" : \"#{note}\", \"NoteType\" : \"Staff\" }") if transaction.present?
      transaction
    end

    private

      def validate_illiad_patron(patron)
        cleared = patron["Cleared"]
        cleared == "Yes"
      end

      def disavowed_illiad_patron?(patron)
        patron["Cleared"] == "DIS"
      end
  end
end
