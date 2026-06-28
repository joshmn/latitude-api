# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class UserProfile < SingletonAPIResource
        resource_type "users"
        resource_path "/user/profile"

        class << self
          def retrieve(opts = {})
            parsed = execute_request(method: :get, path: resource_path, opts: opts)
            construct_from(parsed, opts: opts)
          end

          def update(id, params = {}, opts = {})
            body = JSONAPI.encode(type: resource_type, id: id, attributes: params)
            parsed = execute_request(method: :patch, path: "#{resource_path}/#{URI.encode_www_form_component(id)}",
                                     body: body, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end
      end
    end
  end
end
