# frozen_string_literal: true
require 'faraday'

module Requests
  # This class is responsible for assembling the data to display the Requests form
  class Form
    attr_reader :system_id, :mfhd, :patron, :requestable, :requestable_unrouted, :holdings, :location, :location_code, :pick_ups
    alias default_pick_ups pick_ups
    delegate :eligible_for_library_services?, to: :patron
    delegate :items, :too_many_items?, to: :requestables_list

    include Requests::Bibdata
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd alma holding id
    # @option opts [Patron] :patron current Patron object
    def initialize(system_id:, mfhd:, patron: nil)
      @system_id = system_id
      @holdings = JSON.parse(doc[:holdings_1display] || '{}')
      # scsb items are the only ones that come in without a MFHD parameter from the catalog now
      # set it for them, because they only ever have one location
      @mfhd = mfhd || @holdings.keys.first
      @patron = patron
      @location_code = @holdings[@mfhd]["location_code"] if @holdings[@mfhd].present?
      @location = load_bibdata_location
      @pick_ups = build_pick_ups
      @requestable_unrouted = requestables_list.to_a
      @requestable = route_requests(@requestable_unrouted)
    end

    delegate :user, to: :patron

    def requestable?
      requestable.size.positive?
    end

    def first_filtered_requestable
      requestable&.first
    end

    # Does this request object have any available copies?
    def any_loanable_copies?
      requestable_unrouted.any? do |requestable|
        !(requestable.charged? || (requestable.aeon? || !requestable.circulates? || requestable.partner_holding? || requestable.on_reserve?))
      end
    end

    # returns an array of Requests::Requestable objects that can respond to #services with an array of the relevant services
    def route_requests(requestable_items)
      requestable_items.map do |requestable|
        Requests::Router.new(requestable:, any_loanable: any_loanable_copies?, patron:).routed_request
      end
    end

    def serial?
      doc[:format].present? && doc[:format].include?('Journal')
    end

    # returns basic metadata for hidden fields on the request form via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def hidden_field_metadata
      {
        title: doc["title_citation_display"],
        author: doc["author_citation_display"],
        isbn: doc["isbn_s"]&.values_at(0),
        date: doc["pub_date_display"]
      }
    end

    def ctx
      @ctx ||= Requests::SolrOpenUrlContext.new(solr_doc: doc).ctx
    end

    def doc
      @doc ||= SolrDocument.new(solr_doc(system_id))
    end

    private

      def load_bibdata_location
        return if location_code.blank?
        location = get_location_data(location_code)
        location_object = Location.new location
        location[:delivery_locations] = location_object.sort_pick_ups if location_object.delivery_locations.present?
        location
      end

      def requestables_list
        @requestables_list ||= RequestablesList.new(document: doc, holdings:, mfhd:, location:, patron:)
      end
  end
end
