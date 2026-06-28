# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class APIKey < APIResource
        resource_type "api_keys"
        resource_path "/auth/api_keys"
        id_prefix     "tok_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Update
        extend Operations::Delete

        class << self
          def rotate(id, params = {}, opts = {})
            body = JSONAPI.encode(type: resource_type, id: id, attributes: params)
            parsed = execute_request(method: :put, path: instance_url(id), body: body, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end

        def rotate(params = {}, opts = {})
          self.class.rotate(id, params, opts)
        end
      end
    end
  end
end
