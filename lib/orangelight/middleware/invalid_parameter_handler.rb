# frozen_string_literal: true

module Orangelight
  module Middleware
    class InvalidParameterHandler
      def initialize(app)
        @app = app
      end

      def call(env)
        validate_for!(env)
        @app.call(env)
      rescue ActionController::BadRequest => bad_request_error
        raise bad_request_error unless bad_request_error.message.match?(/invalid %-encoding/)

        Rails.logger.error "Invalid parameters passed in the request: #{bad_request_error} within the environment #{@request.inspect}"
        return bad_request_response
      end

      private

        def request_for(env)
          # calling env.dup here prevents bad things from happening
          @request ||= ActionDispatch::Request.new(env.dup)
        end

        def validate_for!(env)
          # calling request.params is sufficient to trigger the error
          # see https://github.com/rack/rack/issues/337#issuecomment-46453404
          request_for(env).params
        end

        def bad_request_status
          400
        end

        def bad_request_body
          'Bad Request'
        end

        def default_charset
          ActionDispatch::Response.default_charset
        end

        def default_content_type
          'text/html'
        end

        def request_content_type
          @request.formats.first || default_content_type
        end

        def bad_request_headers
          {
            'Content-Type' => "#{request_content_type}; charset=#{default_charset}",
            'Content-Length' => bad_request_body.bytesize.to_s
          }
        end

        def bad_request_response
          [
            bad_request_status,
            bad_request_headers,
            [bad_request_body]
          ]
        end
    end
  end
end
