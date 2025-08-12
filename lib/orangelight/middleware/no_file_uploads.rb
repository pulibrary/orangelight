# frozen_string_literal: true
module Orangelight
  module Middleware
    # This class is responsible for ensuring that users cannot upload temporary files
    # to the server as part of a multipart/form-data request.
    #
    # While these uploaded files are deleted immediately as part of the request cycle
    # and are not placed in a directory where they can do much harm, they can still
    # trip OIT's malicious files sensors and then they take the server off the network.
    #
    # Since we have no need for these files, we reject them.
    class NoFileUploads
      def initialize(app)
        @app = app
      end

      def call(env)
        env['rack.multipart.tempfile_factory'] = lambda { |_filename, _content_type|
          raise 'Sorry, the catalog does not support file uploads'
        }
        app.call env
      end

        private

          attr_reader :app
    end
  end
end
