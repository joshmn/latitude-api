# frozen_string_literal: true

module Latitude
  module API
    class SingletonAPIResource < APIResource
      class << self
        def retrieve(opts = {})
          parsed = execute_request(method: :get, path: resource_path, opts: opts)
          construct_from(parsed, opts: opts)
        end

        def instance_url(_id = nil, path_params: {})
          class_url(path_params: path_params)
        end
      end

      def resource_url
        self.class.resource_path
      end
    end
  end
end
