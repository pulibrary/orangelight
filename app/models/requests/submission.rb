# frozen_string_literal: true
require 'email_validator'

module Requests
  class Submission
    include ActiveModel::Validations

    validates :email, presence: true, email: true, length: { minimum: 5, maximum: 50 }
    validates :user_name, presence: true, length: { minimum: 1, maximum: 50 }
    validates :user_barcode, allow_blank: true, presence: true, length: { minimum: 5, maximum: 14 },
                             format: { with: /(^\d{14}$)/i, message: "Please supply a valid library barcode" }
    validate :item_validations

    def initialize(params, patron)
      @patron = patron
      @items = selected_items(params[:requestable])
      @bib = params[:bib]
      @services = []
      @success_messages = []
    end

    # :reek:DuplicateMethodCall
    def self.new_from_hash(original_hash)
      requestable = original_hash['items']&.map(&:with_indifferent_access) || []
      patron = Patron.new(user: User.find_by(uid: original_hash['patron']['netid']), patron_hash: original_hash['patron'].with_indifferent_access)
      new({ requestable:, bib: original_hash['bib'] }, patron)
    end

    attr_reader :patron, :success_messages

    def email
      @patron.active_email
    end

    def source
      @patron.source
    end

    def user_name
      @patron.netid
    end

    attr_reader :items

    def filter_items_by_service(service)
      @items.select { |item| item["type"] == service }
    end

    def selected_items(requestable_list)
      items = requestable_list.select { |r| r unless r[:selected] == 'false' || !r.key?('selected') }
      items.map { |item| categorize_by_delivery_and_location(item) }
    end

    def item_validations
      validates_with Requests::SelectedItemsValidator
    end

    def user_barcode
      @patron.barcode
    end

    attr_reader :bib

    def id
      @bib[:id]
    end

    def partner_item?(item)
      Requests.config[:recap_partner_locations].keys.include? item["location_code"]
    end

    def service_types
      @types ||= @items.map { |item| item['type'] }.uniq
      @types
    end

    def process_submission
      @services = service_types.map do |type|
        service_by_type(type)
      end
      @services.each(&:handle)

      @success_messages = generate_success_messages(@success_messages)

      @services
    end

    def service_errors
      return [] if @services.blank?
      @services.map(&:errors).flatten
    end

    def pick_up_location
      Requests::BibdataService.delivery_locations.dig(items.first&.dig('pick_up'), "library") || {}
    end

    def marquand?
      items.first["holding_library"] == 'marquand'
    end

    def edd?(item)
      delivery_mode = delivery_mode(item)
      delivery_mode.present? && delivery_mode == "edd"
    end

    # Convert the submission to a hash that is compatible that
    # Sidekiq can safely serialize to JSON for redis.  This means:
    #   * No application-specific objects (unless they are activerecord db objects)
    #   * No ActiveSupport::HashWithIndifferentAccess objects, we can only have Hash objects
    #   * The keys of the hash must all be strings, not symbols
    # See https://github.com/sidekiq/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple
    def to_h
      {
        bib: bib.to_hash.stringify_keys,
        email: email,
        errors: errors.messages.stringify_keys,
        items: items.map { |hash| hash.to_hash.stringify_keys },
        patron: patron.to_h.to_hash.stringify_keys,
        pick_up_location: pick_up_location.to_hash.stringify_keys,
        user_barcode:,
        user_name:
      }.stringify_keys
    end

    private

      def service_by_type(type)
        case type
        when 'on_shelf', 'marquand_in_library', 'annex', 'annex_in_library'
          Requests::Submissions::HoldItem.new(self, service_type: type)
        when 'recap', 'recap_edd', 'recap_in_library', 'recap_marquand_in_library', 'recap_marquand_edd'
          Requests::Submissions::Recap.new(self, service_type: type)
        when 'clancy_in_library'
          Requests::Submissions::Clancy.new(self)
        when 'clancy_edd'
          Requests::Submissions::ClancyEdd.new(self)
        when 'digitize', 'annex_edd', 'marquand_edd', 'clancy_unavailable_edd'
          Requests::Submissions::DigitizeItem.new(self, service_type: type)
        when *inter_library_services
          Requests::Submissions::Illiad.new(self, service_type: type)
        else
          Requests::Submissions::Generic.new(self, service_type: type)
        end
      end

      def categorize_by_delivery_and_location(item)
        library_code = item["library_code"]
        if recap_no_items?(item)
          item["type"] = "recap_no_items"
        elsif print?(item) && library_code == 'annex'
          item["type"] = "annex"
        elsif off_site?(library_code)
          raise Exception, "#{self.class}: Item does not have a delivery mode" unless delivery_mode(item)
          item["type"] = library_code
          item["type"] += "_edd" if edd?(item)
          item["type"] += "_in_library" if in_library?(item)
        elsif item["type"] == "paging"
          item["type"] = "digitize" if edd?(item)
        elsif edd?(item) && library_code.present?
          item["type"] = "digitize"
        elsif print?(item) && library_code.present?
          item["type"] = "on_shelf"
        end
        item
      end

      def in_library?(item)
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "in_library"
      end

      def recap_no_items?(item)
        item["library_code"] == 'recap' && (item["type"] == "digitize_fill_in" || item["type"] == "recap_no_items")
      end

      def off_site?(library_code)
        library_code == 'recap' || library_code == 'marquand' || library_code == 'clancy' || library_code == 'recap_marquand' || library_code == 'clancy_unavailable' || library_code == 'annex'
      end

      def print?(item)
        delivery_mode = delivery_mode(item)
        delivery_mode.present? && delivery_mode == "print"
      end

      def delivery_mode(item)
        item["delivery_mode_#{item['item_id']}"]
      end

      def inter_library_services
        ['ill']
      end

      def generate_success_messages(success_messages)
        @services.each do |service|
          success_messages << service.success_message
          service.send_mail
        end
        success_messages
      end
  end
end
