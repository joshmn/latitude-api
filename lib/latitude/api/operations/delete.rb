# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Delete
        def delete(id, params = {}, opts = {})
          params = params.dup
          path_params = extract_path_params(params, path_param_keys)
          query = RequestParams.encode(params)
          execute_request(
            method: :delete,
            path: instance_url(id, path_params: path_params),
            query: query,
            opts: opts,
          )
          true
        end
      end
    end
  end
end
