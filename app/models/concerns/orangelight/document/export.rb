# frozen_string_literal: true

module Orangelight
  module Document
    module Export
      include ActiveSupport::Concern

      # Override will_export_as method in Blacklight::Document::Export.
      # Exclude certain export formats for records not in Voyager.
      def will_export_as(short_name, content_type = nil)
        return if formats_to_exclude.include? short_name
        super
      end

      private

        def formats
          %i[marc marcxml refworks_marc_txt endnote openurl_ctx_kev]
        end

        def formats_to_exclude
          return [] if voyager?
          formats
        end

        def holding_id
          @holding_id ||= begin
            holdings = JSON.parse(fetch(:holdings_1display, '{}')).first
            holdings.blank? ? nil : holdings[0]
          end
        end

        def voyager?
          return false if fetch(:id, '').start_with?('SCSB')
          return false if %w[thesis numismatics visuals].include? holding_id
          true
        end
    end
  end
end
