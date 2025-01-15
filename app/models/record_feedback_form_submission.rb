# frozen_string_literal: true
# This class is responsible for conveying a
# form submission to the libanswers API,
# which will create a ticket for us to answer
class RecordFeedbackFormSubmission
  # rubocop:disable Metrics/ParameterLists
  def initialize(message:, patron_name:, patron_email:, title:, context:, quid:)
    @message = message
    @patron_name = patron_name
    @patron_email = patron_email
    @title = title
    @context = context
    @quid = quid
  end
  # rubocop:enable Metrics/ParameterLists

  def send_to_libanswers
    Net::HTTP.post uri, body, { Authorization: "Bearer #{token}" }
  end

    private

      attr_reader :patron_name, :patron_email, :context, :title, :quid

      def body
        @body ||= data.to_a.map { |entry| "#{entry[0]}=#{entry[1]}" }.join('&')
      end

      def data
        {
          quid:,
          pquestion: title,
          pdetails: message,
          pname: patron_name,
          pemail: patron_email
        }.compact
      end

      def message
        return "#{@message}\n\nSent from #{context} via LibAnswers API" if context.present?

        "#{@message}\n\nSent via LibAnswers API"
      end

      def uri
        @uri ||= URI('https://faq.library.princeton.edu/api/1.1/ticket/create')
      end

      def token
        @token ||= OAuthToken.find_or_create_by({ service: 'libanswers',
                                                  endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token' }).token
      end
end
