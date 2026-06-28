# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Update
        def update(id, params = {}, opts = {})
          params = params.dup
          path_params = extract_path_params(params, path_param_keys)
          body = JSONAPI.encode(type: resource_type, id: id, attributes: params)
          parsed = execute_request(
            method: :patch,
            path: instance_url(id, path_params: path_params),
            body: body,
            opts: opts,
          )
          construct_from(parsed, opts: opts, path_params: path_params)
        end
      end
    end
  end
end
