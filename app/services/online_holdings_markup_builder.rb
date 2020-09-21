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
                  holding_id: holding_id
                })
  end

  # Generate the link for electronic access information within a record
  # @param url [String] the URL to the service endpoint
  # @param text [String] the label for the link
  def self.electronic_access_link(url, texts)
    markup = if /Open access/.match? texts.first
               link_to(texts.first, url.to_s, target: '_blank')
             elsif %r{(\/catalog\/.+?#view)} =~ url.to_s
               if texts.first == "arks.princeton.edu"
                 link_to('Digital content', $&)
               else
                 link_to(texts.first, $&)
               end
             else
               link_to(texts.first, "#{ENV['proxy_base']}#{url}", target: '_blank', onclick: "ga('send', 'event', 'proxied link', 'click', '#{url}');")

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

      # This should be restructured into #electronic_access_link
      if /getit\.princeton\.edu/.match? url
        # strip to get only the query_string
        marcit_ctx = url.gsub('http://getit.princeton.edu/resolve?', '')
        markup << content_tag(:li, '',
                              id: 'full_text',
                              class: ['availability--panel', 'availability_full-text'],
                              'data-umlaut-full-text' => true,
                              'data-url-marcit' => marcit_ctx)
      end

      markup << content_tag(:li, link.html_safe, class: 'electronic-access')
    end

    unless adapter.umlaut_accessible?
      markup << content_tag(:li, '',
                            id: 'full_text',
                            class: ['availability--panel',
                                    'availability_full-text',
                                    'availability_full-text-alternative'],
                            'data-umlaut-services' => true)
    end

    return content_tag(:ul, markup.html_safe) if electronic_access.count > 1
    markup
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
