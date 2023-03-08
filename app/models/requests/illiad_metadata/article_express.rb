# frozen_string_literal: true
module Requests
  module IlliadMetadata
    class ArticleExpress
      attr_reader :patron, :bib, :item, :note, :cited_pages, :illiad_transaction_status, :attributes

      def initialize(patron:, bib:, item:, note: "Digitization Request", cited_pages: "COVID-19 Campus Closure")
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

        # rubocop:disable Metrics/AbcSize
        def map_metdata
          {
            "Username" => patron.netid, "TransactionStatus" => illiad_transaction_status,
            "RequestType" => "Article", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"),
            "WantedBy" => "Yes, until the semester's", # NOTE: creation fails if we use any other text value
            "PhotoItemAuthor" => bib["author"]&.truncate(100), "PhotoArticleAuthor" => item["edd_author"]&.truncate(100), "PhotoJournalTitle" => bib["title"]&.truncate(255),
            "PhotoItemPublisher" => item["edd_publisher"]&.truncate(40), "ISSN" => bib["isbn"], "CallNumber" => item["edd_call_number"]&.truncate(255),
            "PhotoJournalInclusivePages" => pages&.truncate(30), "CitedIn" => "#{Requests::Config[:pulsearch_base]}/catalog/#{bib['id']}", "PhotoJournalYear" => item["edd_date"],
            "PhotoJournalVolume" => volume_number(item), "PhotoJournalIssue" => item["edd_issue"]&.truncate(30),
            "ItemInfo3" => item["edd_volume_number"]&.truncate(255), "ItemInfo4" => item["edd_issue"]&.truncate(255),
            "CitedPages" => cited_pages, "AcceptNonEnglish" => true, "ESPNumber" => item["edd_oclc_number"]&.truncate(32),
            "DocumentType" => genre, "Location" => item["edd_location"],
            "PhotoArticleTitle" => item["edd_art_title"]&.truncate(250)
          }
        end
        # rubocop:enable Metrics/AbcSize

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
