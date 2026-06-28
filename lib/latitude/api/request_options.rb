# frozen_string_literal: true

module Latitude
  module API
    class RequestOptions
      ALLOWED = %i[
        api_key
        api_version
        api_base
        open_timeout
        read_timeout
        write_timeout
        max_network_retries
        proxy
        idempotency_key
        headers
      ].freeze

      attr_reader :api_key, :api_version, :api_base,
                  :open_timeout, :read_timeout, :write_timeout,
                  :max_network_retries, :proxy,
                  :idempotency_key, :headers

      def initialize(opts = {})
        opts ||= {}
        validate!(opts)
        @api_key              = opts[:api_key]
        @api_version          = opts[:api_version]
        @api_base             = opts[:api_base]
        @open_timeout         = opts[:open_timeout]
        @read_timeout         = opts[:read_timeout]
        @write_timeout        = opts[:write_timeout]
        @max_network_retries  = opts[:max_network_retries]
        @proxy                = opts[:proxy]
        @idempotency_key      = opts[:idempotency_key]
        @headers              = opts[:headers] || {}
      end

      def self.wrap(opts)
        return opts if opts.is_a?(RequestOptions)

        new(opts || {})
      end

      def merge(other)
        other = self.class.wrap(other)
        merged = to_h.merge(other.to_h) { |_k, a, b| b.nil? ? a : b }
        merged[:headers] = @headers.merge(other.headers || {})
        self.class.new(merged)
      end

      def to_h
        {
          api_key: @api_key,
          api_version: @api_version,
          api_base: @api_base,
          open_timeout: @open_timeout,
          read_timeout: @read_timeout,
          write_timeout: @write_timeout,
          max_network_retries: @max_network_retries,
          proxy: @proxy,
          idempotency_key: @idempotency_key,
          headers: @headers,
        }
      end

      def apply_to(config)
        overrides = to_h.compact
        overrides.delete(:idempotency_key)
        overrides.delete(:headers)
        return config if overrides.empty?

        config.dup_with(**overrides)
      end

      private

      def validate!(opts)
        extras = opts.keys.map(&:to_sym) - ALLOWED
        return if extras.empty?

        raise ArgumentError, "unknown request option(s): #{extras.join(', ')}"
      end
    end
  end
end
