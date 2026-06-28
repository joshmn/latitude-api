# frozen_string_literal: true

module Latitude
  module API
    module Util
      module_function

      def symbolize_keys(obj)
        case obj
        when Hash
          obj.each_with_object({}) { |(k, v), h| h[k.to_sym] = symbolize_keys(v) }
        when Array
          obj.map { |v| symbolize_keys(v) }
        else
          obj
        end
      end

      def stringify_keys(obj)
        case obj
        when Hash
          obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys(v) }
        when Array
          obj.map { |v| stringify_keys(v) }
        else
          obj
        end
      end

      def deep_merge(a, b)
        a.merge(b) do |_key, av, bv|
          if av.is_a?(Hash) && bv.is_a?(Hash)
            deep_merge(av, bv)
          else
            bv
          end
        end
      end

      def present?(value)
        !blank?(value)
      end

      def blank?(value)
        value.nil? || (value.respond_to?(:empty?) && value.empty?)
      end

      def redact(hash, sensitive_fields)
        return hash unless hash.is_a?(Hash)

        keys = sensitive_fields.map { |k| k.to_s.downcase }
        hash.each_with_object({}) do |(k, v), out|
          out[k] = if keys.include?(k.to_s.downcase)
                     "[FILTERED]"
                   elsif v.is_a?(Hash)
                     redact(v, sensitive_fields)
                   else
                     v
                   end
        end
      end
    end
  end
end
