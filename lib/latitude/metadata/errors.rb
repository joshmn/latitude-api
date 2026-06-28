# frozen_string_literal: true

module Latitude
  module Metadata
    class Error < StandardError; end
    class Unavailable < Error; end
    class TokenError < Error; end
    class RequestError < Error
      attr_reader :http_status, :http_body

      def initialize(message = nil, http_status: nil, http_body: nil)
        super(message)
        @http_status = http_status
        @http_body = http_body
      end
    end
  end
end
