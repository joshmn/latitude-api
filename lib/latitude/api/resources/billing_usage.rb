# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class BillingUsage < SingletonAPIResource
        resource_type "billing_usage"
        resource_path "/billing/usage"

        class << self
          def retrieve(params = {}, opts = {})
            query = RequestParams.encode(params)
            parsed = execute_request(method: :get, path: resource_path, query: query, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end
      end
    end
  end
end
