# frozen_string_literal: false

# Adapter for SolrDocument instances and the Bibdata Class
class HoldingRequestsAdapter
  attr_reader :document

  # Construct the interface for the Solr Document and Bib. Data API
  # @param document [SolrDocument]
  # @param bib_data_service [Class] Class or singleton used for the bibliographic data service
  def initialize(document, bib_data_service)
    @document = document
    @bib_data_service = bib_data_service
  end

  # Retrieve the ID for the Solr Document
  # @return [String] the ID value
  def doc_id
    @document.fetch('id')
  end

  # Access the holding locations from Bib. Data
  # @return [Hash] location hash structure
  delegate :holding_locations, to: :@bib_data_service

  # Retrieve the holdings information from the Solr Document
  # @return [Hash] holdings values
  def doc_holdings
    values = @document['holdings_1display'] || '{}'
    JSON.parse(values)
  rescue StandardError => error
    Rails.logger.warn error
    {}
  end

  # Retrieve the electronic access information
  # @return [String] electronic access value
  delegate :doc_electronic_access, to: :@document

  # Parse IIIF Manifest links from the electronic access information
  # @return [Hash] IIIF Manifests information
  delegate :iiif_manifests, to: :@document

  # Determine whether or not the electronic resources are accessible using getit
  # @return [TrueClass, FalseClass]
  def getit_accessible?
    doc_electronic_access.keys.any? { |link| /getit\.princeton\.edu/.match(link) }
  end

  # Determine whether or not the electronic resources are accessible using umlaut
  # @return [TrueClass, FalseClass]
  def umlaut_accessible?
    getit_accessible? || doc_electronic_access.empty? || !@document.umlaut_fulltext_eligible?
  end

  # Retrieve only the ELF holding records
  # @return [Hash] ELF holding information
  def doc_holdings_elf
    doc_holdings.select { |_id, h| h['location_code'].start_with?('elf') }
  end

  # Retrieve only the records for physical holdings
  # @return [Hash] physical holding information
  def doc_holdings_physical
    doc_holdings.reject { |_id, h| h['location_code'].start_with?('elf') }
  end
  alias physical_holdings doc_holdings_physical

  # Retrieve the physical holdings records sorted by location code
  # @return [Hash] sorted physical holding information
  def sorted_physical_holdings
    doc_holdings_physical.sort_by do |_id, h|
      @bib_data_service.holding_locations.keys.index(h['location_code'])
    end
  end

  # Retrieve the rules from the bib. data service for each holding
  # @return [Array<Hash>] the location rules
  def rules
    doc_holdings_physical.each_value
                         .map { |holding| holding_location_rules(holding) }
                         .reject(&:nil?)
  end

  # Retrieve the restrictions placed upon physical holdings
  # @return [Array<String>]
  def restrictions
    doc_holdings_physical.each_value.map { |holding| restrictions_for_holding(holding) }
  end

  # Determine whether or not the catalog record is for a periodical
  # @return [TrueClass, FalseClass]
  def journal?
    @document.fetch('format', []).include?('Journal')
  end

  # Retrieve the publication date for the catalog record
  # @return [String] the date value
  def pub_date
    @document.key?('pub_date_start_sort') ? @document['pub_date_start_sort'] : 0
  end

  # Methods for holding values
  # Should these be refactored into static methods
  # (or should a decorator be used for holding values?)

  # Generate a full string for the location values
  # @param location [Hash] location information
  # @return [String] the location string
  def location_full_display(location)
    return location['library']['label'] if location.fetch('label') == ''
    location['library']['label'] + ' - ' + location['label']
  end

  # Retrieve the location rules from holding values
  # @param holding [Hash] the holding values
  # @return [Hash] location values
  def holding_location_rules(holding)
    loc_code = holding.fetch('location_code', nil)
    return loc_code if loc_code.nil?
    @bib_data_service.holding_locations[loc_code.to_sym]
  end

  # Generate the label for a location from the holding values
  # @param holding [Hash] the holding values
  # @return [String] the location label
  def holding_location_label(holding)
    location = holding_location_rules(holding)
    location.nil? ? holding['location'] : location_full_display(location)
  end

  # Retrieve the call number from holding values
  # @param holding [Hash] the holding values
  # @return [String] the call number
  def call_number(holding)
    holding['call_number_browse'] || holding['call_number']
  end

  # Determine whether or not the holding is for a repository item
  # @return [TrueClass, FalseClass]
  def repository_holding?(holding)
    holding['dspace']
  end

  # Determine whether or not the holding is for a SCSB items with ReCAP
  # @return [TrueClass, FalseClass]
  def scsb_holding?(holding)
    /^scsb.+/ =~ holding['location_code']
  end

  # Determine whether or not the holding has no child items
  # @return [TrueClass, FalseClass]
  def empty_holding?(holding)
    holding['items'].nil?
  end

  # Retrieve the restrictions for a given holding
  # Duplicates PhysicalHoldingsMarkupBuilder.scsb_list
  # @param holding [Hash]
  def restrictions_for_holding(holding)
    return [] unless holding.key? 'items'
    holding['items'].select { |values| values['use_statement'].present? }
  end

  # Determine whether or not the holding is explicitly marked as "Unavailable"
  # @return [TrueClass, FalseClass]
  def unavailable_holding?(holding)
    holding['dspace'] == false
  end

  # Determine whether or not the holding has a shelving title
  # @return [TrueClass, FalseClass]
  def shelving_title?(holding)
    !holding['shelving_title'].nil?
  end

  # Determine whether or not the holding has a location note
  # @return [TrueClass, FalseClass]
  def location_note?(holding)
    !holding['location_note'].nil?
  end

  # Determine whether or not the holding features a location
  # @return [TrueClass, FalseClass]
  def location_has?(holding)
    !holding['location_has'].nil?
  end

  # Determine whether or not the holding is for a Voyager
  # @return [TrueClass, FalseClass]
  def voyager_holding?(holding_id)
    return false if @document.fetch(:id, '').start_with?('SCSB')
    return false if %w[thesis visuals].include? holding_id
    true
  end
end
