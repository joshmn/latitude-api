# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class VirtualMachine < APIResource
        resource_type "virtual_machines"
        resource_path "/virtual_machines"
        id_prefix     "vm_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
        extend Operations::Action

        action :power_action, path: "actions", type: "actions", accepts: %i[action]
        action :reboot,       path: "actions", type: "actions", attributes: { action: "reboot" }
        action :power_on,     path: "actions", type: "actions", attributes: { action: "power_on" }
        action :power_off,    path: "actions", type: "actions", attributes: { action: "power_off" }
      end
    end
  end
end
