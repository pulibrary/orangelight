# frozen_string_literal: true

# This module provides the body of an email export based on the document's semantic values
module Blacklight
  module Document
    module Email
      include ActionView::Helpers::UrlHelper

      # Return a text string that will be the body of the email
      def to_email_text
        body = []
        add_bibliographic_text(body)
        add_online_text(body, self[:electronic_access_1display], self[:electronic_portfolio_s])
        body.join("\n") unless body.empty?
      end

      private

        def add_single_valued_field(body, i18_label, value)
          body << I18n.t(i18_label, value:) if value.present?
        end

        def add_multi_valued_field(body, i18_label, value)
          value.each { |v| add_single_valued_field(body, i18_label, v) } if value.present?
        end

        def add_bibliographic_text(body)
          add_single_valued_field(body, 'blacklight.email.text.title', self[:title_vern_display])
          add_single_valued_field(body, 'blacklight.email.text.title', self[:title_display])
          add_multi_valued_field(body, 'blacklight.email.text.author', self[:author_display])
          add_multi_valued_field(body, 'blacklight.email.text.publish', self[:pub_created_display])
          add_multi_valued_field(body, 'blacklight.email.text.format', self[:format])
        end

        def add_online_text(body, links_field, portfolio_fields)
          body << I18n.t('blacklight.email.text.online') if links_field.present? || portfolio_fields.present?
          if links_field.present?
            links = JSON.parse(links_field)
            links.each do |url, text|
              link = "#{text[0]}: #{url}"
              link = "#{text[1]} - " + link if text[1]
              body << "\t" + link
            end
          end
          if portfolio_fields.present?
            portfolio_fields.each do |portfolio_field|
              portfolio = JSON.parse(portfolio_field)
              link = "#{portfolio['title']}: #{portfolio['url']}"
              body << "\t" + link
            end
          end
        end
    end
  end
end
