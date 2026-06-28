# frozen_string_literal: true

module Latitude
  module API
    module Resources
      module Storage
        class Volume < APIResource
          resource_type "volumes"
          resource_path "/storage/volumes"
          id_prefix     "vol_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Retrieve
          extend Operations::Delete

          class << self
            def mount(id, server_id: nil, opts: {})
              attrs = { server_id: server_id }.compact
              body = JSONAPI.encode(type: "volumes", attributes: attrs)
              parsed = execute_request(method: :post, path: "#{instance_url(id)}/mount", body: body, opts: opts)
              parsed
            end
          end

          def mount(server_id: nil, opts: {})
            self.class.mount(id, server_id: server_id, opts: opts)
          end
        end
      end
    end
  end
end
