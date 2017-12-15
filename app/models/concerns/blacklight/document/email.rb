
# This module provides the body of an email export based on the document's semantic values
module Blacklight
  module Document
    module Email
      include Rails.application.routes.url_helpers
      # Return a text string that will be the body of the email
      def to_email_text
        body = []
        add_bibliographic_text(body)
        add_holdings_text(body, self[:holdings_1display])
        add_online_text(body, self[:electronic_access_1display])
        body.join("\n") unless body.empty?
      end

      private

        def add_single_valued_field(body, i18_label, value)
          body << I18n.t(i18_label, value: value) if value.present?
        end

        def add_multi_valued_field(body, i18_label, value)
          value.each { |v| add_single_valued_field(body, i18_label, v) } if value.present?
        end

        def add_holding_fields(body, holding)
          location = holding['location'] || holding['library']
          body << "\t" + I18n.t('blacklight.email.text.location', value: location) if location
          cn = holding['call_number']
          body << "\t" + I18n.t('blacklight.email.text.call_number', value: cn) if cn
        end

        def add_bibliographic_text(body)
          add_single_valued_field(body, 'blacklight.email.text.title', self[:title_vern_display])
          add_single_valued_field(body, 'blacklight.email.text.title', self[:title_display])
          add_multi_valued_field(body, 'blacklight.email.text.author', self[:author_display])
          add_multi_valued_field(body, 'blacklight.email.text.publish', self[:pub_created_display])
          add_multi_valued_field(body, 'blacklight.email.text.format', self[:format])
        end

        def add_holdings_text(body, holdings_field)
          if holdings_field.present?
            body << I18n.t('blacklight.email.text.holdings')
            holdings = JSON.parse(self[:holdings_1display])
            first_holding = true
            holdings.each do |_mfhd, holding|
              body << '' unless first_holding # blank line to separate holdings
              add_holding_fields(body, holding)
              first_holding = false
            end
          end
        end

        def add_online_text(body, links_field)
          if links_field.present?
            body << I18n.t('blacklight.email.text.online')
            links = JSON.parse(links_field)
            links.each do |url, text|
              link = "#{text[0]}: #{url}"
              link = "#{text[1]} - " + link if text[1]
              body << "\t" + link
            end
          end
        end
    end
  end
end
