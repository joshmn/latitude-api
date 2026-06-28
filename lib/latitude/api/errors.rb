# frozen_string_literal: true

module Latitude
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ConnectionError < Error
    attr_reader :cause_error

    def initialize(message = nil, cause: nil)
      super(message)
      @cause_error = cause
    end
  end

  class APIError < Error
    class Entry
      attr_reader :status, :code, :title, :detail, :meta, :raw

      def initialize(raw)
        @raw    = raw || {}
        @status = @raw["status"]
        @code   = @raw["code"]
        @title  = @raw["title"]
        @detail = @raw["detail"] || @raw["message"]
        @meta   = @raw["meta"] || {}
      end

      def to_s
        return @detail.to_s if @title.nil? || @title.empty?
        return @title.to_s if @detail.nil? || @detail.empty?

        "#{@title}: #{@detail}"
      end

      def to_h
        @raw.dup
      end
    end

    attr_reader :http_status, :http_headers, :http_body, :json_body, :request_id, :entries

    def initialize(message = nil, http_status: nil, http_headers: nil, http_body: nil, json_body: nil, request_id: nil)
      @http_status  = http_status
      @http_headers = http_headers || {}
      @http_body    = http_body
      @json_body    = json_body
      @request_id   = request_id
      @entries      = Array(json_body.is_a?(Hash) ? json_body["errors"] : nil).map { |h| Entry.new(h) }
      super(message || default_message)
    end

    alias errors entries

    def code
      entries.first&.code
    end

    def title
      entries.first&.title
    end

    def detail
      entries.first&.detail
    end

    private

    def default_message
      first = entries.first
      return first.to_s if first && !first.to_s.empty?
      return "HTTP #{http_status}" if http_status

      "API error"
    end
  end

  class BadRequestError < APIError; end
  class AuthenticationError < APIError; end

  class PermissionError < APIError
    READ_ONLY_CODES = %w[
      READ_ONLY_API_KEY
      READ_ONLY_KEY
      read_only_api_key
      read_only
    ].freeze

    def read_only_key?
      entries.any? { |e| READ_ONLY_CODES.include?(e.code.to_s) }
    end

    def feature_not_enabled?
      entries.any? { |e| e.code.to_s == "FEATURE_NOT_ENABLED" }
    end
  end

  class NotFoundError < APIError; end
  class ConflictError < APIError; end
  class UnprocessableEntityError < APIError; end

  class RateLimitError < APIError
    def retry_after
      meta_value = entries.map { |e| e.meta["retry_after"] }.compact.first
      return Integer(meta_value) if meta_value

      header_value = http_headers["retry-after"] || http_headers["Retry-After"]
      return Integer(header_value) if header_value && header_value.to_s.match?(/\A\d+\z/)

      nil
    end
  end

  class ServerError < APIError; end

  module API
    class << self
      def error_class_for_status(status)
        case status
        when 400 then BadRequestError
        when 401 then AuthenticationError
        when 403 then PermissionError
        when 404 then NotFoundError
        when 409 then ConflictError
        when 422 then UnprocessableEntityError
        when 429 then RateLimitError
        when 500..599 then ServerError
        else APIError
        end
      end
    end
  end
end
