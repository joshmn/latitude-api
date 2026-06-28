# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class ErrorsTest < Minitest::Test
      def test_error_class_for_status_mapping
        assert_equal BadRequestError,           Latitude::API.error_class_for_status(400)
        assert_equal AuthenticationError,       Latitude::API.error_class_for_status(401)
        assert_equal PermissionError,           Latitude::API.error_class_for_status(403)
        assert_equal NotFoundError,             Latitude::API.error_class_for_status(404)
        assert_equal ConflictError,             Latitude::API.error_class_for_status(409)
        assert_equal UnprocessableEntityError,  Latitude::API.error_class_for_status(422)
        assert_equal RateLimitError,            Latitude::API.error_class_for_status(429)
        assert_equal ServerError,               Latitude::API.error_class_for_status(500)
        assert_equal ServerError,               Latitude::API.error_class_for_status(503)
      end

      def test_rate_limit_retry_after_from_meta
        err = RateLimitError.new(
          nil,
          http_status: 429,
          json_body: {
            "errors" => [{
              "status" => "429", "code" => "RATE_LIMIT_EXCEEDED",
              "title" => "Rate Limit Exceeded", "meta" => { "retry_after" => 60 },
            }],
          },
        )
        assert_equal 60, err.retry_after
      end

      def test_rate_limit_retry_after_from_header_when_meta_missing
        err = RateLimitError.new(
          nil,
          http_status: 429,
          http_headers: { "retry-after" => "15" },
          json_body: { "errors" => [{ "status" => "429", "meta" => {} }] },
        )
        assert_equal 15, err.retry_after
      end

      def test_permission_error_feature_not_enabled_predicate
        err = PermissionError.new(
          nil,
          http_status: 403,
          json_body: { "errors" => [{ "code" => "FEATURE_NOT_ENABLED", "message" => "Elastic IPs is not enabled" }] },
        )
        assert err.feature_not_enabled?
        refute err.read_only_key?
      end

      def test_api_error_exposes_entries
        err = NotFoundError.new(
          nil,
          http_status: 404,
          json_body: { "errors" => [{ "status" => "404", "code" => "not_found", "title" => "Error",
                                      "detail" => "Specified Record Not Found" }] },
        )
        assert_equal "not_found", err.code
        assert_equal "Specified Record Not Found", err.detail
        assert_equal 1, err.entries.size
        assert_match(/Error: Specified Record Not Found/, err.message)
      end
    end
  end
end
