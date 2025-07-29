# frozen_string_literal: true
# This class is responsible for assembling the URL for the user
# to return to the record they were viewing prior to entering the
# requests system
class Requests::BackToRecordUrl
  def initialize(input_params)
    @input_params = input_params.permit(:system_id, :open_holdings)
  end

  def to_s
    Rails.application.routes.url_helpers.solr_document_path output_params
  end

    private

      attr_reader :input_params

      def output_params
        { id: system_id, open_holdings: }.compact
      end

      def system_id
        input_params[:system_id]
      end

      def open_holdings
        input_params[:open_holdings]
      end
end
