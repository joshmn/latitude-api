# frozen_string_literal: true

module Latitude
  module API
    class Configuration
      DEFAULT_API_BASE                   = "https://api.latitude.sh"
      DEFAULT_OPEN_TIMEOUT               = 30
      DEFAULT_READ_TIMEOUT               = 80
      DEFAULT_WRITE_TIMEOUT              = 30
      DEFAULT_MAX_NETWORK_RETRIES        = 0
      DEFAULT_INITIAL_NETWORK_RETRY_DELAY = 0.5
      DEFAULT_MAX_NETWORK_RETRY_DELAY    = 5.0
      DEFAULT_SENSITIVE_FIELDS           = %w[
        authorization
        public_key
        private_key
        password
        api_key
        token
        kubeconfig
        credentials
        ipmi_password
      ].freeze

      attr_accessor :api_key,
                    :api_base,
                    :api_version,
                    :open_timeout,
                    :read_timeout,
                    :write_timeout,
                    :max_network_retries,
                    :initial_network_retry_delay,
                    :max_network_retry_delay,
                    :proxy,
                    :verify_ssl_certs,
                    :ca_bundle_path,
                    :ca_store,
                    :logger,
                    :log_level,
                    :app_info,
                    :enable_telemetry,
                    :sensitive_fields

      def initialize
        @api_key                     = nil
        @api_base                    = DEFAULT_API_BASE
        @api_version                 = nil
        @open_timeout                = DEFAULT_OPEN_TIMEOUT
        @read_timeout                = DEFAULT_READ_TIMEOUT
        @write_timeout               = DEFAULT_WRITE_TIMEOUT
        @max_network_retries         = DEFAULT_MAX_NETWORK_RETRIES
        @initial_network_retry_delay = DEFAULT_INITIAL_NETWORK_RETRY_DELAY
        @max_network_retry_delay     = DEFAULT_MAX_NETWORK_RETRY_DELAY
        @proxy                       = nil
        @verify_ssl_certs            = true
        @ca_bundle_path              = nil
        @ca_store                    = nil
        @logger                      = nil
        @log_level                   = :info
        @app_info                    = nil
        @enable_telemetry            = true
        @sensitive_fields            = DEFAULT_SENSITIVE_FIELDS.dup
      end

      def dup_with(**overrides)
        copy = Configuration.new
        instance_variables.each do |ivar|
          copy.instance_variable_set(ivar, instance_variable_get(ivar))
        end
        overrides.each { |k, v| copy.public_send("#{k}=", v) }
        copy
      end

      def api_base_uri
        URI.parse(@api_base)
      rescue URI::InvalidURIError => e
        raise ConfigurationError, "api_base is not a valid URL: #{@api_base.inspect} (#{e.message})"
      end

      def validate_api_key!
        return unless @api_key.nil? || @api_key.to_s.empty?

        raise ConfigurationError,
              "No API key provided. Set it via Latitude.api_key = '...' or pass api_key: in request options."
      end
    end
  end
end
