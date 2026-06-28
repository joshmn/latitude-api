# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Action
        def action(name, path:, type: nil, method: :post, attributes: {}, accepts: nil, returns: :raw)
          action_method = method.to_sym
          action_path   = path
          action_type   = type
          action_attrs  = attributes
          accepts_keys  = accepts ? Array(accepts).map(&:to_sym) : nil
          returns_mode  = returns

          define_singleton_method(name) do |id, params = {}, opts = {}|
            params = params.dup
            path_params = extract_path_params(params, path_param_keys)
            if accepts_keys
              unknown = params.keys.map(&:to_sym) - accepts_keys
              raise ArgumentError, "unknown action params: #{unknown.join(', ')}" unless unknown.empty?
            end
            body_attrs = action_attrs.merge(params)
            body = if action_type
                     JSONAPI.encode(type: action_type, attributes: body_attrs)
                   elsif !body_attrs.empty?
                     JSON.generate(body_attrs)
                   end
            url = "#{instance_url(id, path_params: path_params)}/#{action_path}"
            parsed = execute_request(method: action_method, path: url, body: body, opts: opts)
            returns_mode == :instance ? construct_from(parsed, opts: opts, path_params: path_params) : parsed
          end

          define_method(name) do |params = {}, opts = {}|
            merged = @path_params.merge(params || {})
            self.class.public_send(name, id, merged, opts)
          end
        end
      end
    end
  end
end
