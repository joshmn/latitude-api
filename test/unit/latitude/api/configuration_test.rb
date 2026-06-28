# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class ConfigurationTest < Minitest::Test
      def test_defaults
        Latitude.reset_config!
        assert_equal "https://api.latitude.sh", Latitude.api_base
        assert_equal 30, Latitude.open_timeout
        assert_equal 80, Latitude.read_timeout
        assert_equal 0, Latitude.max_network_retries
        assert_nil Latitude.api_version
        assert_nil Latitude.logger
      end

      def test_configure_block_yields_config
        Latitude.reset_config!
        Latitude.configure do |c|
          c.api_key = "lat_abc"
          c.api_version = "2023-06-01"
          c.max_network_retries = 3
        end
        assert_equal "lat_abc", Latitude.api_key
        assert_equal "2023-06-01", Latitude.api_version
        assert_equal 3, Latitude.max_network_retries
      end

      def test_dup_with_overrides
        base = Latitude.config
        base.api_key = "k1"
        dup = base.dup_with(api_key: "k2", read_timeout: 5)
        assert_equal "k1", base.api_key
        assert_equal "k2", dup.api_key
        assert_equal 5, dup.read_timeout
      end

      def test_validate_api_key_raises_when_blank
        Latitude.reset_config!
        error = assert_raises(ConfigurationError) { Latitude.config.validate_api_key! }
        assert_match(/No API key provided/, error.message)
      end
    end
  end
end
