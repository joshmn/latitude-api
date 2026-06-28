# frozen_string_literal: true

require "httparty"

module Latitude
  module API
    class RequestExecutor
      RETRIABLE_STATUSES = [429, 500, 502, 503, 504].freeze
      RETRIABLE_EXCEPTIONS = [
        EOFError,
        Errno::ECONNREFUSED,
        Errno::ECONNRESET,
        Errno::EPIPE,
        Net::OpenTimeout,
        Net::ReadTimeout,
        OpenSSL::SSL::SSLError,
        SocketError,
      ].freeze

      def initialize(config)
        @config = config
      end

      def execute(method:, path:, query: nil, body: nil, headers: {}, idempotency_key: nil, extra_headers: {})
        @config.validate_api_key!

        url = build_url(path, query)
        request_headers = build_headers(method, headers, idempotency_key, extra_headers)
        options = build_httparty_options(request_headers, body)

        attempts = 0
        max_retries = @config.max_network_retries

        loop do
          attempts += 1
          started = Time.now
          response = nil
          begin
            response = HTTParty.send(method.to_sym, url.to_s, options)
          rescue *RETRIABLE_EXCEPTIONS => e
            log_exception(e, method, path, attempts)
            raise ConnectionError.new("Network error talking to #{url}: #{e.message}", cause: e) if attempts > max_retries

            sleep(backoff_delay(attempts, nil))
            next
          end

          duration = ((Time.now - started) * 1000).round
          log_response(method, path, response, duration)

          if retriable_status?(response.code) && attempts <= max_retries
            sleep(backoff_delay(attempts, response))
            next
          end

          return handle_response(response, method: method, path: path)
        end
      end

      private

      def build_url(path, query)
        base = URI.parse(@config.api_base)
        resolved = path.start_with?("http://", "https://") ? URI.parse(path) : URI.join("#{base}/", path.sub(%r{^/}, ""))
        if query && !query.empty?
          resolved.query = [resolved.query, query].compact.reject(&:empty?).join("&")
        end
        resolved
      end

      def build_headers(method, headers, idempotency_key, extra_headers)
        h = {}
        h["Authorization"]  = "Bearer #{@config.api_key}"
        h["Accept"]         = JSONAPI::MEDIA_TYPE
        h["Content-Type"]   = "application/json" if %i[post put patch].include?(method.to_sym)
        h["User-Agent"]     = user_agent
        h["API-Version"]    = @config.api_version if @config.api_version
        h["Idempotency-Key"] = idempotency_key if idempotency_key

        (headers || {}).each { |k, v| h[k.to_s] = v.to_s }
        (extra_headers || {}).each { |k, v| h[k.to_s] = v.to_s }
        h
      end

      def build_httparty_options(headers, body)
        options = {
          headers: headers,
          open_timeout: @config.open_timeout,
          read_timeout: @config.read_timeout,
          follow_redirects: false,
          format: :plain,
        }
        options[:write_timeout] = @config.write_timeout if @config.write_timeout
        options[:verify] = @config.verify_ssl_certs
        options[:ca_path] = @config.ca_bundle_path if @config.ca_bundle_path
        options[:body] = body if body

        if @config.proxy
          proxy_uri = URI.parse(@config.proxy)
          options[:http_proxyaddr] = proxy_uri.host
          options[:http_proxyport] = proxy_uri.port
          options[:http_proxyuser] = proxy_uri.user if proxy_uri.user
          options[:http_proxypass] = proxy_uri.password if proxy_uri.password
        end
        options
      end

      def handle_response(response, method:, path:)
        status  = response.code
        body    = response.body
        headers = normalize_headers(response.headers)
        request_id = headers["x-request-id"] || headers["request-id"]

        if status.between?(200, 299)
          return nil if body.nil? || body.empty? || status == 204

          return JSONAPI.parse(body)
        end

        parsed = begin
          JSONAPI.parse(body)
        rescue StandardError
          nil
        end
        klass = Latitude::API.error_class_for_status(status)
        raise klass.new(
          nil,
          http_status: status,
          http_headers: headers,
          http_body: body,
          json_body: parsed,
          request_id: request_id,
        )
      end

      def normalize_headers(headers)
        return {} if headers.nil?

        result = {}
        headers.each { |k, v| result[k.to_s.downcase] = v.is_a?(Array) ? v.first : v }
        result
      end

      def retriable_status?(status)
        RETRIABLE_STATUSES.include?(status.to_i)
      end

      def backoff_delay(attempt, response)
        if response && response.code.to_i == 429
          retry_after = extract_retry_after(response)
          return retry_after.to_f if retry_after
        end
        base  = @config.initial_network_retry_delay
        max   = @config.max_network_retry_delay
        delay = base * (2**(attempt - 1))
        jitter = delay * (rand * 0.5)
        [max, delay + jitter].min
      end

      def extract_retry_after(response)
        headers = normalize_headers(response.headers)
        header = headers["retry-after"]
        return Integer(header) if header && header.to_s.match?(/\A\d+\z/)

        body = response.body
        return nil if body.nil? || body.empty?

        parsed = begin
          JSONAPI.parse(body)
        rescue StandardError
          nil
        end
        errors = parsed.is_a?(Hash) ? Array(parsed["errors"]) : []
        errors.each do |e|
          meta = e["meta"] || {}
          return Integer(meta["retry_after"]) if meta["retry_after"]
        end
        nil
      end

      def user_agent
        parts = ["Latitude/v1 RubyBindings/#{VERSION}"]
        parts << "(#{RUBY_ENGINE} #{RUBY_VERSION}; #{RUBY_PLATFORM})"
        if (info = @config.app_info)
          app = +"#{info[:name]}"
          app << "/#{info[:version]}" if info[:version]
          app << " (#{info[:url]})" if info[:url]
          parts << app
        end
        parts.join(" ")
      end

      def log_response(method, path, response, duration_ms)
        logger = @config.logger
        return unless logger

        logger.info("latitude-api #{method.to_s.upcase} #{path} status=#{response.code} dur=#{duration_ms}ms")
        return unless logger.debug?

        parsed = begin
          JSON.parse(response.body.to_s)
        rescue StandardError
          response.body
        end
        redacted = Util.redact(parsed, @config.sensitive_fields)
        logger.debug("latitude-api response: #{redacted.inspect[0..4096]}")
      end

      def log_exception(exception, method, path, attempt)
        logger = @config.logger
        return unless logger

        logger.warn("latitude-api #{method.to_s.upcase} #{path} attempt=#{attempt} error=#{exception.class}: #{exception.message}")
      end
    end
  end
end
