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
          Blacklight::Configuration::ToolConfig.new(callback: :email_action, validator: :validate_email_params, partial: "document_action", name: :email, key: :email),
          Blacklight::Configuration::ToolConfig.new(modal: false, partial: "document_action", name: :print, key: :print),
          Blacklight::Configuration::ToolConfig.new(modal: false, partial: "document_action", name: :csv, key: :csv, path: :csv_bookmarks_path, label: 'CSV')
        ]
      end

      def options
        { document_list: documents }
      end
      attr_reader :documents, :url_opts
end
