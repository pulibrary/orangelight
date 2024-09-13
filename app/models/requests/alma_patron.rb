# frozen_string_literal: true
module Requests
  # Create a Patron from the Alma gem API directly, rather than via Bibdata
  class AlmaPatron
    def initialize(uid:)
      @uid = uid
    end

    def hash
      {
        last_name:,
        active_email:,
        barcode:,
        barcode_status: 1,
        netid: "ALMA",
        university_id: uid
      }.with_indifferent_access
    end

    private

      def alma_user
        @alma_user ||= Alma::User.find(uid)
      end

      def barcode
        active_barcode || "ALMA"
      end

      def active_barcode
        alma_user["user_identifier"].find do |id|
          id["id_type"]["value"] == "BARCODE" && id["status"] == "ACTIVE"
        end["value"]
      end

      def last_name
        alma_user.preferred_last_name
      end

      def active_email
        alma_user.preferred_email
      end

      attr_reader :uid
  end
end
