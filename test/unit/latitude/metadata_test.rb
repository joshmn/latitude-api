# frozen_string_literal: true

require "test_helper"

module Latitude
  class MetadataTest < Minitest::Test
    IMDS_BASE = "http://169.254.169.254/metadata/v1"

    def setup
      super
      Latitude::Metadata.reset!
    end

    def test_session_fetches_token_and_then_metadata_field
      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token")
             .with(headers: { "X-Metadata-Token-TTL-Seconds" => "3600" })
             .to_return(status: 200, body: "session_token_abc")

      WebMock.stub_request(:get, "#{IMDS_BASE}/hostname")
             .with(headers: { "X-Metadata-Token" => "session_token_abc" })
             .to_return(status: 200, body: "my-server")

      assert_equal "my-server", Latitude::Metadata.hostname
    end

    def test_all_returns_deep_wrapped_object
      full = {
        "instance_id" => "sv_1",
        "hostname" => "h",
        "network" => { "interfaces" => [{ "name" => "eth0" }] },
      }

      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token").to_return(status: 200, body: "tok")
      WebMock.stub_request(:get, "#{IMDS_BASE}/metadata.json")
             .with(headers: { "X-Metadata-Token" => "tok" })
             .to_return(status: 200, body: JSON.generate(full))

      meta = Latitude::Metadata.all
      assert_equal "sv_1", meta.instance_id
      assert_equal "eth0", meta.network.interfaces.first.name
    end

    def test_json_path_parses_structured_body
      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token").to_return(status: 200, body: "tok")
      WebMock.stub_request(:get, "#{IMDS_BASE}/tags")
             .to_return(status: 200, body: JSON.generate([{ "key" => "env", "value" => "prod" }]))

      tags = Latitude::Metadata.tags
      assert_equal "env", tags.first.key
      assert_equal "prod", tags.first.value
    end

    def test_unavailable_when_service_unreachable
      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token").to_raise(Errno::EHOSTUNREACH.new("No route"))

      error = assert_raises(Latitude::Metadata::Unavailable) { Latitude::Metadata.hostname }
      assert_match(/only works from within a Latitude/, error.message)
    end

    def test_token_error_wraps_http_failure
      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token").to_return(status: 500, body: "fail")

      assert_raises(Latitude::Metadata::TokenError) { Latitude::Metadata.hostname }
    end

    def test_token_reused_across_calls
      WebMock.stub_request(:put, "#{IMDS_BASE}/api/token").to_return(status: 200, body: "tok")
      WebMock.stub_request(:get, "#{IMDS_BASE}/hostname").to_return(status: 200, body: "h")
      WebMock.stub_request(:get, "#{IMDS_BASE}/region").to_return(status: 200, body: "SAO")

      Latitude::Metadata.hostname
      Latitude::Metadata.region

      assert_requested(:put, "#{IMDS_BASE}/api/token", times: 1)
    end
  end
end
