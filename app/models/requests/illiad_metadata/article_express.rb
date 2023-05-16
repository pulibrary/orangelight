# frozen_string_literal: true
module Requests
  module IlliadMetadata
    class ArticleExpress
      attr_reader :patron, :bib, :item, :note, :cited_pages, :illiad_transaction_status, :attributes

      def initialize(patron:, bib:, item:, note: "Digitization Request", cited_pages: '')
        @patron = patron
        @bib = bib
        @item = item
        @note = note
        @note = "#{@note}: #{item['edd_note']}".truncate(4000) if item["edd_note"].present?
        @cited_pages = cited_pages.truncate(30)
        @illiad_transaction_status = "Awaiting Article Express Processing"
        @attributes = map_metdata
      end

      private

        def map_metdata
          Metadata.new(
            patron.netid, illiad_transaction_status, "Article", "Borrowing",
            (DateTime.current + 6.months).strftime("%m/%d/%Y"),
            "Yes, until the semester's", # NOTE: creation fails if we use any other text value
            bib["author"]&.truncate(100), item["edd_author"]&.truncate(100),
            bib["title"]&.truncate(255), item["edd_publisher"]&.truncate(40),
            bib["isbn"], item["edd_call_number"]&.truncate(255),
            pages&.truncate(30),
            "#{Requests::Config[:pulsearch_base]}/catalog/#{bib['id']}",
            item["edd_date"], volume_number(item),
            item["edd_issue"]&.truncate(30),
            item["edd_volume_number"]&.truncate(255),
            item["edd_issue"]&.truncate(255), cited_pages,
            true, item["edd_oclc_number"]&.truncate(32),
            genre, item["edd_location"],
            item["edd_art_title"]&.truncate(250)
          ).to_metadata_hash
        end

        def pages
          "#{item['edd_start_page']}-#{item['edd_end_page']}"
        end

        def genre
          case item["edd_genre"]
          when "article"
            "Article"
          when "bookitem"
            "Book Chapter"
          when "dissertation"
            "Thesis"
          else
            "Book"
          end
        end

        def volume_number(item)
          vol = []
          vol << item["user_supplied_enum"] if item["user_supplied_enum"].present?
          vol << item["edd_volume_number"] if item["edd_volume_number"].present?
          vol.join(', ')&.truncate(30)
        end
    end
  end
end
