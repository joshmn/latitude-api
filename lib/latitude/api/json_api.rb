# frozen_string_literal: true

module Latitude
  module API
    module JSONAPI
      MEDIA_TYPE = "application/vnd.api+json"

      module_function

      def envelope(type:, attributes: nil, id: nil, relationships: nil)
        data = { "type" => type.to_s }
        data["id"] = id.to_s if id
        data["attributes"] = Util.stringify_keys(attributes) if attributes
        data["relationships"] = Util.stringify_keys(relationships) if relationships
        { "data" => data }
      end

      def encode(type:, attributes: nil, id: nil, relationships: nil)
        JSON.generate(envelope(type: type, attributes: attributes, id: id, relationships: relationships))
      end

      def parse(body)
        return nil if body.nil? || body.empty?

        JSON.parse(body)
      rescue JSON::ParserError => e
        raise APIError.new(
          "Invalid JSON response from server: #{e.message}",
          http_body: body,
        )
      end

      def extract_errors(parsed)
        return [] unless parsed.is_a?(Hash)

        Array(parsed["errors"])
      end
    end
  end
end
