# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Plan < APIResource
        resource_type "plans"
        resource_path "/plans"
        id_prefix     "plan_"

        extend Operations::List
        extend Operations::Retrieve

        class OperatingSystem < APIResource
          resource_type "operating_system"
          resource_path "/plans/operating_systems"

          extend Operations::List
        end

        class Bandwidth < APIResource
          resource_type "bandwidth_plan"
          resource_path "/plans/bandwidth"

          extend Operations::List

          class << self
            def update_packages(attributes = {}, opts = {})
              body = JSONAPI.encode(type: "bandwidth_packages", attributes: attributes)
              execute_request(method: :post, path: resource_path, body: body, opts: opts)
            end
          end
        end

        class Storage < APIResource
          resource_type "storage_plans"
          resource_path "/plans/storage"

          extend Operations::List
        end

        class VirtualMachine < APIResource
          resource_type "virtual_machine_plans"
          resource_path "/plans/virtual_machines"

          extend Operations::List
        end
      end
    end
  end
end
