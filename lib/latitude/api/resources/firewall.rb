# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Firewall < APIResource
        resource_type "firewalls"
        resource_path "/firewalls"
        id_prefix     "firewall_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class << self
          def assignments
            Assignment
          end
        end

        class Assignment < APIResource
          resource_type "firewall_assignments"
          resource_path "/firewalls/:firewall_id/assignments"

          extend Operations::List
          extend Operations::Create
          extend Operations::Delete

          class << self
            def list_all(params = {}, opts = {})
              query = RequestParams.encode(params)
              parsed = execute_request(method: :get, path: "/firewalls/assignments", query: query, opts: opts)
              ListObject.new(resource_class: self, parsed: parsed, request_params: params, request_opts: opts)
            end
          end
        end
      end
    end
  end
end
