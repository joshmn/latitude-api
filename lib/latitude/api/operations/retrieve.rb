# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Retrieve
        def retrieve(id, params = {}, opts = {})
          params = params.dup
          path_params = extract_path_params(params, path_param_keys)
          query = RequestParams.encode(params)
          parsed = execute_request(
            method: :get,
            path: instance_url(id, path_params: path_params),
            query: query,
            opts: opts,
          )
          construct_from(parsed, opts: opts, path_params: path_params)
        end
      end
    end
  end
end
