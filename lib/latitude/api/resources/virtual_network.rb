# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class VirtualNetwork < APIResource
        resource_type "virtual_networks"
        resource_path "/virtual_networks"
        id_prefix     "vlan_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class Assignment < APIResource
          resource_type "virtual_network_assignment"
          resource_path "/virtual_networks/assignments"

          extend Operations::List
          extend Operations::Delete

          class << self
            def create(params = {}, opts = {})
              body = JSONAPI.encode(type: resource_type, attributes: params)
              parsed = execute_request(method: :post, path: resource_path, body: body, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
