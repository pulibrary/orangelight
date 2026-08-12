# frozen_string_literal: true

# This component is responsible for displaying detailed
# online holdings, such as on the record show page

class Holdings::FullOnlineHoldingsComponent < ViewComponent::Base
  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  def initialize(adapter)
    @adapter = adapter
  end

  private

    attr_reader :adapter

    def all_portfolios = (adapter.electronic_portfolios || []) + (adapter.sibling_electronic_portfolios || [])

    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    def portfolios
      @portfolios ||= if all_portfolios[0]&.key?('thesis')
                        []
                      else
                        all_portfolios.map do |portfolio|
                          start_date = portfolio['start']
                          end_date = portfolio['end']
                          date_range = "#{start_date} - #{end_date}: " if start_date && end_date
                          {
                            label: "#{date_range}#{portfolio['title']}",
                            url: portfolio['url'],
                            desc: portfolio['desc'],
                            notes: portfolio['notes']&.join(', ') || ''
                          }
                        end
                      end
    end

    def render?
      !electronic_access_links.empty? || portfolios.any?
    end

    # Generate a block of markup for an online holding
    # @param bib_id [String] the ID for the SolrDocument
    # @param holding_id [String] the ID for the holding
    # @return [String] the markup
    def online_link(bib_id, holding_id)
      children = helpers.content_tag(
        :span, 'Link Missing',
        class: 'lux-text-style gray strong'
      )
      # AJAX requests are made using availability.js here
      # rubocop:disable Rails/OutputSafety
      helpers.content_tag(:div, children.html_safe,
                          class: 'holding-block',
                          data: {
                            availability_record: true,
                            record_id: bib_id,
                            holding_id:
                          })
      # rubocop:enable Rails/OutputSafety
    end

    # Generate the link for electronic access information within a record 856 field
    # @param url [String] the URL to the service endpoint
    # @param text [String] the label for the link
    # :reek:TooManyStatements
    # :reek:DuplicateMethodCall
    def electronic_access_link(url, texts)
      if texts.first.include?('Open access')
        link_to(texts.first, url.to_s, target: '_blank', rel: 'noopener', class: 'electronic-access-link')
      elsif %r{(/catalog/.+?#view)} =~ url.to_s
        if texts.first == "arks.princeton.edu"
          link_to('Digital content', ::Regexp.last_match(0), class: 'electronic-access-link')
        else
          link_to(texts.first, ::Regexp.last_match(0), class: 'electronic-access-link')
        end
      else
        link_text = new_tab_icon(texts.first)
        link_to(link_text, url.to_s, target: '_blank', rel: 'noopener', class: 'electronic-access-link')
      end
    end

    # Method for cleaning URLs
    # @param url [String] the URL for an online holding
    # @return [String] the cleaned URL
    # :reek:UtilityFunction
    def clean_url(url)
      if /go\.galegroup\.com.+?%257C/.match? url
        URI.decode_www_form_component(url)
      else
        url
      end
    end

    # Generate the markup for the electronic access block based on 856 links in the record
    # Proxy Base is added to force remote access when appropriate
    # @return [String] the markup
    # :reek:TooManyStatements
    # :reek:DuplicateMethodCall
    def electronic_access_links
      markup = ''

      electronic_access = adapter.doc_electronic_access
      # rubocop:disable Rails/OutputSafety
      electronic_access.each do |url, electronic_texts|
        texts = electronic_texts.flatten
        url = clean_url(url)

        link = electronic_access_link(url, texts)
        link = "#{texts[1]}: " + link if texts[1]
        link = "<li>#{link}</li>" if electronic_access.many?
        markup += helpers.content_tag(:li, link.html_safe, class: 'electronic-access')
      end

      return helpers.content_tag(:ul, markup.html_safe) if electronic_access.many?
      markup
      # rubocop:enable Rails/OutputSafety
    end

    # :reek:FeatureEnvy
    def new_tab_icon(text)
      # rubocop:disable Rails/OutputSafety
      text = text.html_safe
      # rubocop:enable Rails/OutputSafety
      text + helpers.content_tag(:i, "", class: "fa fa-external-link new-tab-icon-padding", 'aria-label': "opens in new tab", role: "img")
    end
end
