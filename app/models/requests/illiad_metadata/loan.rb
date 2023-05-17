# frozen_string_literal: true
module Requests
  module IlliadMetadata
    class Loan
      attr_reader :patron, :bib, :item, :note, :illiad_transaction_status, :attributes

      def initialize(patron:, bib:, item:, note: "Loan Request")
        @patron = patron
        @bib = bib
        @item = item
        @note = note&.truncate(4000)
        @illiad_transaction_status = "Awaiting Request Processing"
        @attributes = map_metdata
      end

      private

        # TODO: where do I find LoanEdition?

        def map_metdata
          {
            "Username" => patron.netid, "TransactionStatus" => illiad_transaction_status,
            "RequestType" => "Loan", "ProcessType" => "Borrowing", "NotWantedAfter" => (DateTime.current + 6.months).strftime("%m/%d/%Y"),
            "WantedBy" => "Yes, until the semester's", # NOTE: creation fails if we use any other text value
            "LoanAuthor" => bib["author"]&.truncate(100), "LoanTitle" => bib["title"]&.truncate(255),
            "LoanPublisher" => item["edd_publisher"]&.truncate(40), "LoanDate" => bib["date"],
            "ISSN" => bib["isbn"], "CallNumber" => call_number(item),
            "CitedIn" => "#{Requests::Config[:pulsearch_base]}/catalog/#{bib['id']}",
            "ItemInfo3" => volume_number(item)&.truncate(255), "ItemInfo4" => item["edd_issue"]&.truncate(255),
            "AcceptNonEnglish" => true, "ESPNumber" => item["edd_oclc_number"]&.truncate(32),
            "DocumentType" => genre, "LoanPlace" => item["edd_location"]
          }
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
          vol = [item["user_supplied_enum"], item["edd_volume_number"], item["enum"]].compact_blank
          vol.join(', ')&.truncate(30)
        end

        def call_number(item)
          call_no = item["edd_call_number"] || item["call_number"]
          call_no&.truncate(255)
        end
    end
  end
end
