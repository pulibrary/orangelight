# frozen_string_literal: true
require 'faraday'

module Requests
  class Patron
    attr_reader :user, :session, :patron_hash, :errors

    delegate :guest?, :provider, :cas_provider?, :alma_provider?, to: :user

    def initialize(user:, session: {}, patron_hash: nil)
      @user = user
      @session = session
      @errors = []
      # load the patron_hash from bibdata unless we are passing it in
      @patron_hash = patron_hash || load_patron(user:)
    end

    def barcode
      patron_hash[:barcode]
    end

    def active_email
      patron_hash[:active_email] || ldap[:email]
    end

    def first_name
      patron_hash[:first_name] || ldap[:givenname]
    end

    def last_name
      patron_hash[:last_name] || ldap[:surname]
    end

    def netid
      patron_hash[:netid]
    end

    def patron_id
      patron_hash[:patron_id]
    end

    def patron_group
      patron_hash[:patron_group]
    end

    def university_id
      patron_hash[:university_id]
    end

    def eligible_for_library_services?
      barcode.present?
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
      patron_hash[:ldap] || {}
    end

    def blank?
      patron_hash.empty?
    end

    def to_h
      patron_hash
    end

    private

      def load_patron(user:)
        if !user.guest?
          patron_hash = current_patron_hash(user.uid)
          errors << "A problem occurred looking up your library account." if patron_hash.nil?
          # Uncomment to fake being a non barcoded user
          # patron_hash[:barcode] = nil
          patron_hash || {}
        elsif session["email"].present? && session["user_name"].present?
          AccessPatron.new(session:).hash
        else
          {}
        end
      end

      def current_patron_hash(uid)
        return unless uid

        if alma_provider?
          alma_patron_hash(uid:)
        else
          full_patron = FullPatron.new(uid:)
          errors.concat(full_patron.errors)
          full_patron.hash
        end
      end

      # This method uses the Alma gem API to build the patron from Alma directly, rather than via Bibdata
      def alma_patron_hash(uid:)
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
  end
end
