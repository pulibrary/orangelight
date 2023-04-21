# frozen_string_literal: true

module Requests
  module IlliadMetadata
    class Metadata
      def initialize(username, transaction_status, request_type, process_type, not_wanted_after,
                     wanted_by, photo_item_author, photo_article_author, photo_journal_title,
                     photo_item_publisher, issn, call_number, photo_journal_inclusive_pages, cited_in,
                     photo_journal_year, photo_journal_volume, photo_journal_issue, item_info3,
                     item_info4, cited_pages, accept_non_english, esp_number, document_type, location,
                     photo_article_title)
        @username = username
        @transaction_status = transaction_status
        @request_type = request_type
        @process_type = process_type
        @not_wanted_after = not_wanted_after
        @wanted_by = wanted_by
        @photo_item_author = photo_item_author
        @photo_article_author = photo_article_author
        @photo_journal_title = photo_journal_title
        @photo_item_publisher = photo_item_publisher
        @issn = issn
        @call_number = call_number
        @photo_journal_inclusive_pages = photo_journal_inclusive_pages
        @cited_in = cited_in
        @photo_journal_year = photo_journal_year
        @photo_journal_volume = photo_journal_volume
        @photo_journal_issue = photo_journal_issue
        @item_info3 = item_info3
        @item_info4 = item_info4
        @cited_pages = cited_pages
        @accept_non_english = accept_non_english
        @esp_number = esp_number
        @document_type = document_type
        @location = location
        @photo_article_title = photo_article_title
      end

      def to_metadata_hash
        {
          "Username" => @username,
          "TransactionStatus" => @transaction_status,
          "RequestType" => @request_type,
          "ProcessType" => @process_type,
          "NotWantedAfter" => @not_wanted_after,
          "WantedBy" => @wanted_by,
          "PhotoItemAuthor" => @photo_item_author,
          "PhotoArticleAuthor" => @photo_article_author,
          "PhotoJournalTitle" => @photo_journal_title,
          "PhotoItemPublisher" => @photo_item_publisher,
          "ISSN" => @issn,
          "CallNumber" => @call_number,
          "PhotoJournalInclusivePages" => @photo_journal_inclusive_pages,
          "CitedIn" => @cited_in,
          "PhotoJournalYear" => @photo_journal_year,
          "PhotoJournalVolume" => @photo_journal_volume,
          "PhotoJournalIssue" => @photo_journal_issue,
          "ItemInfo3" => @item_info3,
          "ItemInfo4" => @item_info4,
          "CitedPages" => @cited_pages,
          "AcceptNonEnglish" => @accept_non_english,
          "ESPNumber" => @esp_number,
          "DocumentType" => @document_type,
          "Location" => @location,
          "PhotoArticleTitle" => @photo_article_title
        }
      end
    end
  end
end
