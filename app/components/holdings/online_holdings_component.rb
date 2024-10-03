# frozen_string_literal: true

# This component is responsible for displaying a brief description of
# a document's online holdings for consice contexts like the search
# results page
class Holdings::OnlineHoldingsComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  def render?
    links.present?
  end

  private

    attr_reader :document

    def links
      @links ||= marc_links + portfolio_links
    end

    # Generate an Array of <div> elements wrapping links to proxied service endpoints for access
    # Takes first 2 links for pairing with online holdings in search results
    # @return [Array<String>] array containing the links in the <div>'s
    def marc_links
      electronic_access = document['electronic_access_1display']
      urls = []
      if electronic_access
        links_hash = JSON.parse(electronic_access)
        links_hash.first(2).each do |url, text|
          link = link_to(text.first, EzProxyService.ez_proxy_url(url), target: '_blank', rel: 'noopener')
          link = "#{text[1]}: ".html_safe + link if text[1]
          urls << content_tag(:div, link, class: 'library-location')
        end
      end
      urls
    end

    # Returns electronic portfolio links for Alma records.
    # @return [Array<String>] array containing the links
    def portfolio_links
      return [] if document.try(:electronic_portfolios).blank?
      document.electronic_portfolios.map do |portfolio|
        content_tag(:div, class: 'library-location') do
          link_to(portfolio["title"], portfolio["url"], target: '_blank', rel: 'noopener')
        end
      end
    end
end
