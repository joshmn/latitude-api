# frozen_string_literal: true

require "test_helper"

module Latitude
  module API
    class ApiObjectTest < Minitest::Test
      def test_dot_access
        obj = APIObject.new("hostname" => "web", "plan" => { "slug" => "c2-small-x86" })
        assert_equal "web", obj.hostname
        assert_instance_of APIObject, obj.plan
        assert_equal "c2-small-x86", obj.plan.slug
      end

      def test_arrays_are_wrapped
        obj = APIObject.new("tags" => [{ "name" => "prod" }, { "name" => "db" }])
        assert_equal "prod", obj.tags.first.name
      end

      def test_to_h_roundtrips
        data = { "a" => 1, "b" => { "c" => 2 }, "d" => [{ "e" => 3 }] }
        obj = APIObject.new(data)
        assert_equal data, obj.to_h
      end

      def test_predicate_method
        obj = APIObject.new("locked" => true, "rescue_allowed" => false)
        assert obj.locked?
        refute obj.rescue_allowed?
      end

      def test_missing_key_raises
        obj = APIObject.new("a" => 1)
        assert_raises(NoMethodError) { obj.nonexistent }
      end
    end
  end
end
