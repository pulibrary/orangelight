# frozen_string_literal: true
require 'faraday'

module Requests
  class Patron
    attr_reader :user, :session, :patron, :errors

    delegate :guest?, :provider, :barcode_provider?, :cas_provider?, :alma_provider?, to: :user

    def initialize(user:, session: {}, patron: nil)
      @user = user
      @session = session
      @errors = []
      # load the patron from bibdata unless we are passing it in
      @patron = patron || load_patron(user:)
    end

    def barcode
      patron[:barcode]
    end

    def active_email
      patron[:active_email] || ldap[:email]
    end

    def first_name
      patron[:first_name] || ldap[:givenname]
    end

    def last_name
      patron[:last_name] || ldap[:surname]
    end

    def netid
      patron[:netid]
    end

    def patron_id
      patron[:patron_id]
    end

    def patron_group
      patron[:patron_group]
    end

    def university_id
      patron[:university_id]
    end

    def source
      patron[:source]
    end

    def eligible_for_library_services?
      barcode.present?
    end

    def undergraduate?
      pustatus == "undergraduate"
    end

    def telephone
      ldap[:telephone]
    end

    def status
      ldap[:status]
    end

    def pustatus
      ldap[:pustatus]
    end

    def department
      ldap[:department]
    end

    def title
      ldap[:title]
    end

    def address
      ldap[:address]
    end

    def ldap
      patron[:ldap] || {}
    end

    def blank?
      patron.empty?
    end

    def to_h
      patron
    end

    private

      def load_patron(user:)
        if !user.guest?
          patron = current_patron(user.uid)
          errors << "A problem occurred looking up your library account." if patron.nil?
          # Uncomment to fake being a non barcoded user
          # patron[:barcode] = nil
          patron || {}
        elsif session["email"].present? && session["user_name"].present?
          access_patron(session["email"], session["user_name"])
        else
          {}
        end
      end

      def bibdata_uri
        Requests::Config[:bibdata_base]
      end

      def build_patron_uri(uid:)
        "#{bibdata_uri}/patron/#{uid}"
      end

      def api_request_patron(id:)
        request_uri = build_patron_uri(uid: id)
        response = Faraday.get("#{request_uri}?ldap=true")

        case response.status
        when 500
          Rails.logger.error('Error Patron Data Service.')
        when 429
          error_message = "The maximum number of HTTP requests per second for the Alma API has been exceeded."
          Rails.logger.error(error_message)
          errors << error_message
        when 404
          Rails.logger.error("404 Patron #{id} cannot be found in the Patron Data Service.")
        when 403
          Rails.logger.error("403 Not Authorized to Connect to Patron Data Service at #{request_uri} for patron ID #{id}")
        else
          return response unless response.body.empty?

          Rails.logger.error("#{bibdata_uri} returned an empty patron response")
        end
        nil
      rescue Faraday::Error::ConnectionFailed
        Rails.logger.error("Unable to connect to #{bibdata_uri}")
        nil
      end

      def current_patron(uid)
        return unless uid

        if alma_provider?
          build_alma_patron(uid:)
        else
          build_cas_patron(uid:)
        end
      end

      def build_access_patron(email:, user_name:)
        {
          last_name: user_name,
          active_email: email,
          barcode: 'ACCESS',
          barcode_status: 0
        }
      end

      def access_patron(email, user_name)
        built = build_access_patron(email:, user_name:)
        built.with_indifferent_access
      end

      def access_patron?
        barcode == "ACCESS"
      end

      # This method uses the Alma gem API to build the patron from Alma, rather than via Bibdata
      def build_alma_patron(uid:)
        alma_user = Alma::User.find(uid)
        active_barcode = alma_user["user_identifier"].find { |id| id["id_type"]["value"] == "BARCODE" && id["status"] == "ACTIVE" }["value"]
        {
          last_name: alma_user.preferred_last_name,
          active_email: alma_user.preferred_email,
          barcode: active_barcode || "ALMA",
          barcode_status: 1,
          netid: "ALMA",
          university_id: uid
        }
      end

      def build_cas_patron(uid:)
        api_response = api_request_patron(id: uid)
        return if api_response.nil?

        patron_resource = JSON.parse(api_response.body)
        patron_resource.with_indifferent_access
      rescue JSON::ParserError
        Rails.logger.error("#{api_response.env.url} returned an invalid patron response: #{api_response.body}")
        false
      end
  end
end
