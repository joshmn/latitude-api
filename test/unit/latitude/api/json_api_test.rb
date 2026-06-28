# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class JsonApiTest < Minitest::Test
      def test_envelope_create_shape
        body = JSONAPI.envelope(type: "servers", attributes: { hostname: "x", plan: "c2-small-x86" })
        assert_equal "servers", body["data"]["type"]
        assert_equal({ "hostname" => "x", "plan" => "c2-small-x86" }, body["data"]["attributes"])
        refute body["data"].key?("id")
      end

      def test_envelope_update_shape_includes_id
        body = JSONAPI.envelope(type: "servers", id: "sv_1", attributes: { hostname: "y" })
        assert_equal "sv_1", body["data"]["id"]
        assert_equal({ "hostname" => "y" }, body["data"]["attributes"])
      end

      def test_encode_returns_json_string
        json = JSONAPI.encode(type: "projects", attributes: { name: "x" })
        parsed = JSON.parse(json)
        assert_equal "projects", parsed["data"]["type"]
        assert_equal "x", parsed["data"]["attributes"]["name"]
      end

      def test_parse_returns_hash
        parsed = JSONAPI.parse('{"data":{"id":"x","type":"servers"}}')
        assert_equal "x", parsed["data"]["id"]
      end

      def test_parse_returns_nil_for_blank
        assert_nil JSONAPI.parse(nil)
        assert_nil JSONAPI.parse("")
      end

      def test_parse_raises_on_invalid_json
        assert_raises(APIError) { JSONAPI.parse("not json") }
      end
    end
  end
end
