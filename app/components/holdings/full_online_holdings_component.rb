# frozen_string_literal: true

# This component is responsible for displaying detailed
# online holdings, such as on the record show page

class Holdings::FullOnlineHoldingsComponent < ViewComponent::Base
  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  def initialize(adapter)
    @adapter = adapter
  end

  # Data from an 856 field used to render a link
  LinkData = Data.define(:url, :texts, :link_to) do
    def link_description = texts[1]
    def viewer_url? = url.to_s.match?(%r{(/catalog/.+?#view)})
    def link_text = first_text == 'arks.princeton.edu' ? 'Digital content' : first_text
    def first_text = texts.first
  end

  private

    attr_reader :adapter

    delegate :deduplication?, to: Flipflop

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
                            notes: portfolio['notes']&.join(', ') || '',
                            display_format: portfolio['display_format']
                          }
                        end
                      end
    end

    def render?
      electronic_access_links.any? || portfolios.any?
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

    def electronic_access_links
      adapter.doc_electronic_access.map do |url, electronic_texts|
        LinkData.new(clean_url(url), electronic_texts.flatten, method(:link_to))
      end
    end

    def new_tab_icon
      helpers.content_tag(:i, "", class: "fa fa-external-link new-tab-icon-padding", 'aria-label': "opens in new tab", role: "img")
    end

    def css_class
      if deduplication?
        'electronic-access-link important-link'
      else
        'electronic-access-link'
      end
    end
end
