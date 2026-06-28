# frozen_string_literal: true

module Latitude
  module API
    module Resources
      module Storage
        class Object < APIResource
          resource_type "object_storages"
          resource_path "/storage/objects"
          id_prefix     "objs_"

          extend Operations::List
          extend Operations::Retrieve
          extend Operations::Delete

          class << self
            def create(params = {}, opts = {})
              body = JSONAPI.encode(type: "objects", attributes: params)
              parsed = execute_request(method: :post, path: resource_path, body: body, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
