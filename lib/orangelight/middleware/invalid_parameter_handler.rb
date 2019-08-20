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
        raise bad_request_error if raise_error?(bad_request_error.message)

        Rails.logger.error "Invalid parameters passed in the request: #{bad_request_error} within the environment #{@request.inspect}"
        return bad_request_response(env)
      end

      private

        def bad_request_body(env)
          return 'Bad Request' unless request_content_type(env) == default_content_type
          render_error_page
        end

        def bad_request_headers(env)
          {
            'Content-Type' => "#{request_content_type(env)}; charset=#{default_charset}",
            'Content-Length' => bad_request_body(env).bytesize.to_s
          }
        end

        def bad_request_response(env)
          [
            bad_request_status,
            bad_request_headers(env),
            [bad_request_body(env)]
          ]
        end

        def bad_request_status
          400
        end

        def default_charset
          ActionDispatch::Response.default_charset
        end

        def default_content_type
          'text/html'
        end

        # Check if facet fields have empty value lists
        def facet_fields_values(params)
          facet_parameter = params.fetch(:f, [])
          raise ActionController::BadRequest, "Invalid facet parameter passed: #{facet_parameter}" unless facet_parameter.is_a?(Array) || facet_parameter.is_a?(Hash)

          facet_parameter.collect do |facet_field, value_list|
            next unless value_list.nil?
            raise ActionController::BadRequest, "Facet field #{facet_field} has a nil value"
          end
        end

        # Check if params have key with leading or trailing whitespaces
        def check_for_white_spaces(params)
          params.each_key do |k|
            next unless ((k[0].match?(/\s/) || k[-1].match?(/\s/)) && (k.is_a? String)) == true
            raise ActionController::BadRequest, "Param '#{k}' contains a space"
          end
        end

        def raise_error?(message)
          valid_message_patterns.each do |pattern|
            return false if message.match?(pattern)
          end
        end

        def request_content_type(env)
          request = request_for(env)
          request.formats.first || default_content_type
        end

        def request_for(env)
          # calling env.dup here prevents bad things from happening
          ActionDispatch::Request.new(env.dup)
        end

        def valid_message_patterns
          [
            /invalid %-encoding/,
            /Facet field/,
            /Invalid facet/,
            /contains a space/
          ]
        end

        def validate_for!(env)
          # calling request.params is sufficient to trigger an error
          # see https://github.com/rack/rack/issues/337#issuecomment-46453404
          params = request_for(env).params
          check_for_white_spaces(params)
          facet_fields_values(params)
        end

        # Renders the standard Orangelight error page
        def render_error_page
          # Create Warden proxy for devise integration
          proxy = Warden::Proxy.new({}, Warden::Manager.new({}))
          renderer = ApplicationController.renderer.new('warden' => proxy)
          renderer.render('errors/error')
        end
    end
  end
end
