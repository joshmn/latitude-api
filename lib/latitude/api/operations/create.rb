# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Create
        def create(params = {}, opts = {})
          params = params.dup
          path_params = extract_path_params(params, path_param_keys)
          body = JSONAPI.encode(type: resource_type, attributes: params)
          parsed = execute_request(
            method: :post,
            path: class_url(path_params: path_params),
            body: body,
            opts: opts,
          )
          construct_from(parsed, opts: opts, path_params: path_params)
        end
      end
    end
  end
end
