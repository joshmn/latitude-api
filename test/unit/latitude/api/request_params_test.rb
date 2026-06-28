# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class RequestParamsTest < Minitest::Test
      def test_encodes_flat_params
        assert_equal "project=proj_1", RequestParams.encode(project: "proj_1")
      end

      def test_encodes_nested_filter_params
        q = RequestParams.encode(filter: { project: "proj_1", ram: { gte: 32 } })
        assert_includes q, "filter%5Bproject%5D=proj_1"
        assert_includes q, "filter%5Bram%5D%5Bgte%5D=32"
      end

      def test_encodes_page_params
        q = RequestParams.encode(page: { size: 50, number: 2 })
        assert_includes q, "page%5Bsize%5D=50"
        assert_includes q, "page%5Bnumber%5D=2"
      end

      def test_encodes_boolean_as_string
        q = RequestParams.encode(filter: { gpu: true })
        assert_includes q, "filter%5Bgpu%5D=true"
      end

      def test_skips_nil_values
        q = RequestParams.encode(a: "x", b: nil)
        assert_equal "a=x", q
      end

      def test_comma_joins_tag_arrays
        q = RequestParams.encode(filter: { tags: %w[tag_1 tag_2] })
        assert_includes q, "filter%5Btags%5D=tag_1%2Ctag_2"
      end

      def test_filter_modifiers_prefix_suffix_match
        q = RequestParams.encode(filter: { hostname: { prefix: "web" }, name: { match: "workloads" } })
        assert_includes q, "filter%5Bhostname%5D%5Bprefix%5D=web"
        assert_includes q, "filter%5Bname%5D%5Bmatch%5D=workloads"
      end

      def test_encode_sort_handles_string_symbol_and_array
        assert_equal "name", RequestParams.encode_sort("name")
        assert_equal "-created_at", RequestParams.encode_sort(:"-created_at")
        assert_equal "name,-created_at", RequestParams.encode_sort([:name, "-created_at"])
      end

      def test_encodes_time_as_iso8601
        t = Time.utc(2026, 1, 14, 15, 57, 10)
        q = RequestParams.encode(filter: { date: { gte: t } })
        assert_includes q, "filter%5Bdate%5D%5Bgte%5D=2026-01-14T15%3A57%3A10Z"
      end
    end
  end
end
