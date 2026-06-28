# frozen_string_literal: true

module Latitude
  module API
    class APIObject
      RESERVED = %i[attributes id type meta values].freeze

      attr_reader :raw

      def self.wrap(value)
        case value
        when Hash
          new(value)
        when Array
          value.map { |v| wrap(v) }
        else
          value
        end
      end

      def initialize(hash = {})
        @raw = hash || {}
        @values = {}
        @raw.each { |k, v| @values[k.to_s] = self.class.wrap(v) }
      end

      def [](key)
        @values[key.to_s]
      end

      def key?(key)
        @values.key?(key.to_s)
      end

      def keys
        @values.keys
      end

      def each(&blk)
        @values.each(&blk)
      end

      def to_h
        @values.each_with_object({}) do |(k, v), out|
          out[k] = unwrap(v)
        end
      end

      alias to_hash to_h

      def as_json(*_)
        to_h
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        to_h == other.to_h
      end

      alias eql? ==

      def hash
        to_h.hash
      end

      def inspect
        "#<#{self.class.name} #{to_h.inspect}>"
      end

      def respond_to_missing?(name, include_private = false)
        key = normalize_method_name(name)
        return true if @values.key?(key)
        return true if key.end_with?("?") && @values.key?(key.chomp("?"))

        super
      end

      def method_missing(name, *args, &blk)
        key = normalize_method_name(name)
        return @values[key] if @values.key?(key) && args.empty?
        return !!@values[key.chomp("?")] if key.end_with?("?") && @values.key?(key.chomp("?")) && args.empty?

        super
      end

      private

      def normalize_method_name(name)
        name.to_s
      end

      def unwrap(value)
        case value
        when APIObject then value.to_h
        when Array     then value.map { |v| unwrap(v) }
        else value
        end
      end
    end
  end
end
