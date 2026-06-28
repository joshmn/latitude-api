# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Traffic < SingletonAPIResource
        resource_type "traffic"
        resource_path "/traffic"

        class << self
          def retrieve(params = {}, opts = {})
            query = RequestParams.encode(params)
            parsed = execute_request(method: :get, path: resource_path, query: query, opts: opts)
            construct_from(parsed, opts: opts)
          end

          def quota(opts = {})
            parsed = execute_request(method: :get, path: "#{resource_path}/quota", opts: opts)
            Quota.construct_from(parsed, opts: opts)
          end
        end

        class Quota < SingletonAPIResource
          resource_type "traffic_quota"
          resource_path "/traffic/quota"

          class << self
            def retrieve(opts = {})
              parsed = execute_request(method: :get, path: resource_path, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
