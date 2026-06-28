# frozen_string_literal: true

module Latitude
  module Metadata
    class Session
      BASE_URL = "http://169.254.169.254/metadata/v1"
      TOKEN_REFRESH_RATIO = 0.9

      JSON_PATHS = %w[tags network storage ssh_keys vendor].freeze
      UNAVAILABLE_EXCEPTIONS = [
        Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH,
        Errno::ENETUNREACH,
        Errno::ETIMEDOUT,
        Net::OpenTimeout,
        Net::ReadTimeout,
        SocketError,
      ].freeze

      def initialize(ttl: DEFAULT_TTL_SECONDS, open_timeout: 2, read_timeout: 3)
        @ttl = Integer(ttl)
        @open_timeout = open_timeout
        @read_timeout = read_timeout
        @mutex = Mutex.new
        @token = nil
        @token_expires_at = nil
      end

      def token
        @mutex.synchronize { refresh_token_if_needed }
      end

      def refresh_token!
        @mutex.synchronize { fetch_new_token }
      end

      def all
        body = get("metadata.json")
        wrap(JSON.parse(body))
      rescue JSON::ParserError => e
        raise RequestError.new("Invalid JSON from metadata service: #{e.message}")
      end

      def fetch(path)
        path = path.to_s.sub(%r{\A/}, "")
        body = get(path)
        if JSON_PATHS.include?(path) || path == "metadata.json"
          begin
            wrap(JSON.parse(body))
          rescue JSON::ParserError
            body
          end
        else
          body
        end
      end

      private

      def wrap(value)
        Latitude::API::APIObject.wrap(value)
      end

      def get(path)
        perform_request(:get, "#{BASE_URL}/#{path}", headers: { "X-Metadata-Token" => token })
      end

      def perform_request(method, url, headers: {}, body: nil)
        options = {
          headers: headers,
          open_timeout: @open_timeout,
          read_timeout: @read_timeout,
          follow_redirects: false,
          format: :plain,
        }
        options[:body] = body if body

        response = HTTParty.send(method, url, options)

        if response.code.between?(200, 299)
          response.body
        else
          raise RequestError.new("metadata service returned #{response.code}", http_status: response.code,
                                                                               http_body: response.body)
        end
      rescue *UNAVAILABLE_EXCEPTIONS => e
        raise Unavailable, "metadata service unreachable (#{e.class}: #{e.message}). " \
                           "This only works from within a Latitude.sh bare metal server."
      end

      def refresh_token_if_needed
        fetch_new_token if @token.nil? || @token_expires_at.nil? || Time.now >= @token_expires_at
        @token
      end

      def fetch_new_token
        body = perform_request(:put, "#{BASE_URL}/api/token",
                               headers: { "X-Metadata-Token-TTL-Seconds" => @ttl.to_s })
        raise TokenError, "empty token response" if body.nil? || body.strip.empty?

        @token = body.strip
        @token_expires_at = Time.now + (@ttl * TOKEN_REFRESH_RATIO)
        @token
      rescue RequestError => e
        raise TokenError, "could not obtain metadata token: #{e.message}"
      end
    end
  end
end
