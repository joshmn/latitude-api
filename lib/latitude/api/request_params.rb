# frozen_string_literal: true

module Latitude
  module API
    module RequestParams
      COMMA_JOIN_LEAVES = %w[tags extra_fields].freeze

      module_function

      def encode(params)
        return "" if params.nil? || params.empty?

        parts = []
        flatten(params, nil, parts)
        parts.map { |k, v| "#{URI.encode_www_form_component(k)}=#{URI.encode_www_form_component(v)}" }.join("&")
      end

      def flatten(value, parent_key, parts)
        case value
        when Hash
          value.each do |k, v|
            next if v.nil?

            key = parent_key ? "#{parent_key}[#{k}]" : k.to_s
            flatten(v, key, parts)
          end
        when Array
          if comma_join?(parent_key, value)
            parts << [parent_key, value.map(&:to_s).join(",")]
          else
            value.each_with_index do |v, _i|
              flatten(v, "#{parent_key}[]", parts)
            end
          end
        when nil
          nil
        when true, false
          parts << [parent_key, value.to_s]
        else
          parts << [parent_key, scalar(value)]
        end
      end

      def comma_join?(parent_key, value)
        return false unless parent_key
        return false unless value.all? { |v| v.is_a?(String) || v.is_a?(Symbol) || v.is_a?(Numeric) }

        leaf = parent_key.split(/[\[\]]/).reject(&:empty?).last
        COMMA_JOIN_LEAVES.include?(leaf)
      end

      def scalar(value)
        case value
        when Time, DateTime
          value.utc.iso8601
        when Date
          value.iso8601
        else
          value.to_s
        end
      end

      def encode_sort(value)
        return nil if value.nil?

        Array(value).map(&:to_s).reject(&:empty?).join(",")
      end
    end
  end
end
