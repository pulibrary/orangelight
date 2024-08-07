# frozen_string_literal: true
# This class is responsible for conveying a
# form submission to the libanswers API,
# which will create a ticket for us to answer
class FeedbackFormSubmission
  def initialize(message:, patron_name:, patron_email:, user_agent:, current_url:)
    @message = message
    @patron_name = patron_name
    @patron_email = patron_email
    @user_agent = user_agent
    @current_url = current_url
  end

  def send_to_libanswers
    Net::HTTP.post uri, body, { Authorization: "Bearer #{token}" }
  end

    private

      attr_reader :patron_name, :patron_email, :user_agent, :current_url

      def body
        @body ||= data.to_a.map { |entry| "#{entry[0]}=#{entry[1]}" }.join('&')
      end

      def data
        {
          quid: Rails.application.config_for(:orangelight)[:feedback_form][:queue_id],
          pquestion: 'Princeton University Library Catalog Feedback Form',
          pdetails: message,
          pname: patron_name,
          pemail: patron_email,
          ua: user_agent
        }.compact
      end

      def message
        return "#{@message}\n\nSent from #{current_url} via LibAnswers API" if current_url

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
