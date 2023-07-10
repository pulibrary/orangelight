# frozen_string_literal: false

class OnlineHoldingsMarkupBuilder < HoldingRequestsBuilder
  # Generate a block of markup for an online holding
  # @param bib_id [String] the ID for the SolrDocument
  # @param holding_id [String] the ID for the holding
  # @return [String] the markup
  def self.online_link(bib_id, holding_id)
    children = content_tag(
      :span, 'Link Missing',
      class: 'availability-icon badge badge-secondary',
      title: 'Availability: Online',
      'data-toggle' => 'tooltip'
    )
    # AJAX requests are made using availability.js here
    content_tag(:div, children.html_safe,
                class: 'holding-block',
                data: {
                  availability_record: true,
                  record_id: bib_id,
                  holding_id:
                })
  end

  # Generate the link for electronic access information within a record
  # @param url [String] the URL to the service endpoint
  # @param text [String] the label for the link
  def self.electronic_access_link(url, texts)
    markup = if /Open access/.match? texts.first
               link_to(texts.first, url.to_s, target: '_blank', rel: 'noopener')
             elsif %r{(\/catalog\/.+?#view)} =~ url.to_s
               if texts.first == "arks.princeton.edu"
                 link_to('Digital content', ::Regexp.last_match(0))
               else
                 link_to(texts.first, ::Regexp.last_match(0))
               end
             else
               link_text = self.new_tab_icon(texts.first)
               link_to(link_text, EzProxyService.ez_proxy_url(url), target: '_blank', rel: 'noopener')
             end
    markup
  end

  # Method for cleaning URLs
  # @see https://github.com/pulibrary/orangelight/issues/1185
  # @param url [String] the URL for an online holding
  # @return [String] the cleaned URL
  def self.clean_url(url)
    if /go\.galegroup\.com.+?%257C/.match? url
      URI.decode_www_form_component(url)
    else
      url
    end
  end

  # Generate the markup for the electronic access block
  # First argument of link_to is optional display text. If null, the second argument
  # (URL) is the display text for the link.
  # Proxy Base is added to force remote access when appropriate
  # @param adapter [HoldingRequestsAdapter] the adapter for Solr and Bibdata
  # @return [String] the markup
  def self.urlify(adapter)
    markup = ''

    electronic_access = adapter.doc_electronic_access
    electronic_access.each do |url, electronic_texts|
      texts = electronic_texts.flatten
      url = clean_url(url)

      link = electronic_access_link(url, texts)
      link = "#{texts[1]}: " + link if texts[1]
      link = "<li>#{link}</li>" if electronic_access.count > 1
      markup << content_tag(:li, link.html_safe, class: 'electronic-access')
    end

    return content_tag(:ul, markup.html_safe) if electronic_access.count > 1
    markup
  end

  # Returns electronic portforlio link markup.
  # Replaces Umlaut AJAX data when using Alma.
  # @param adapter [HoldingRequestsAdapter] the adapter for Solr and Bibdata
  # @return [String] the markup
  def self.electronic_portfolio_markup(adapter)
    markup = ''

    portfolios = adapter.electronic_portfolios + adapter.sibling_electronic_portfolios
    return '' if portfolios.present? && portfolios[0].key?('thesis')
    portfolios.each do |portfolio|
      start_date = portfolio['start']
      end_date = portfolio['end']
      date_range = "#{start_date} - #{end_date}: " if start_date && end_date
      label = self.new_tab_icon("#{date_range}#{portfolio['title']}")
      link = link_to(label, portfolio["url"], target: '_blank', rel: 'noopener')
      link += " #{portfolio['desc']}"
      link = "#{link} (#{portfolio['notes'].join(', ')})" if portfolio['notes']&.any?
      markup << content_tag(:li, link.html_safe, class: 'electronic-access')
    end

    markup
  end

  def self.new_tab_icon(text)
    text = text.html_safe
    text += content_tag(:i, "", class: "fa fa-external-link new-tab-icon-padding", "aria-label": "opens in new tab", role: "img")
  end

  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  def initialize(adapter)
    @adapter = adapter
  end

  # Builds the markup for online and physical holdings for a given record
  # @return [Array<String>] the markup for the online and physical holdings
  def build
    online_holdings_block
  end

  private

    # Generate the markup for the online holdings
    # @return [String] the markup
    def online_holdings
      markup = ''

      electronic_access_links = self.class.urlify(@adapter)
      markup << electronic_access_links
      elf_holdings = @adapter.doc_holdings_elf

      if electronic_access_links.empty?
        elf_holdings.each_key do |holding_id|
          markup << self.class.online_link(@adapter.doc_id, holding_id)
        end
      end

      # For Alma records, add links from the electronic portfolio field
      markup << self.class.electronic_portfolio_markup(@adapter)

      markup
    end

    # Generate the markup for the online holdings block
    # @return [String] the markup
    def online_holdings_block
      markup = ''
      children = online_holdings
      markup = self.class.content_tag(:ul, children.html_safe) unless children.empty?
      markup
    end
end
