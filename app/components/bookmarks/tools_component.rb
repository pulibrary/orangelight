# frozen_string_literal: true

# This component allows a user to see and use various tools to work with their bookmarked titles
class Bookmarks::ToolsComponent < ViewComponent::Base
  def initialize(documents:, url_opts: {})
    @documents = documents
    @url_opts = url_opts
  end

    private

      # :reek:UtilityFunction
      def actions
        [
          Blacklight::Configuration::ToolConfig.new(callback: :email_action, validator: :validate_email_params, partial: "document_action", name: :email, key: :email, path: url_with_params(email_bookmarks_path), label: 'Email'),
          Blacklight::Configuration::ToolConfig.new(modal: false, partial: "document_action", name: :print, key: :print, path: url_with_params(print_bookmarks_path), label: 'Print'),
          Blacklight::Configuration::ToolConfig.new(modal: false, partial: "document_action", name: :csv, key: :csv, path: url_with_params(csv_bookmarks_path), label: 'CSV')
        ]
      end

      def url_with_params(base_path)
        return base_path if url_opts.blank?
        uri = URI.parse(base_path)
        uri.query = merged_query(uri, url_opts)
        uri.to_s
      end

      # :reek:UtilityFunction
      def merged_query(uri, opts)
        existing_params = Rack::Utils.parse_nested_query(uri.query || "")
        merged_params = existing_params.merge(opts)
        merged_params.to_query.presence
      end

      def options
        { document_list: documents }
      end
      attr_reader :documents, :url_opts
end
