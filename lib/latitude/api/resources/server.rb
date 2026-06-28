# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Server < APIResource
        resource_type "servers"
        resource_path "/servers"
        id_prefix     "sv_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
        extend Operations::Action

        action :power_action,      path: "actions",        type: "actions",      accepts: %i[action]
        action :reboot,            path: "actions",        type: "actions",      attributes: { action: "reboot" }
        action :power_on,          path: "actions",        type: "actions",      attributes: { action: "power_on" }
        action :power_off,         path: "actions",        type: "actions",      attributes: { action: "power_off" }
        action :reset,             path: "actions",        type: "actions",      attributes: { action: "reset" }
        action :lock,              path: "lock"
        action :unlock,            path: "unlock"
        action :rescue_mode,       path: "rescue_mode"
        action :exit_rescue_mode,  path: "exit_rescue_mode"
        action :remote_access,     path: "remote_access"
        action :schedule_deletion, path: "schedule_deletion",
                                   accepts: %i[at reason]
        action :unschedule_deletion, path: "schedule_deletion", method: :delete

        action :reinstall,         path: "reinstall",      type: "reinstalls",
                                   accepts: %i[operating_system ipxe hostname ssh_keys user_data raid partitions]

        action :create_out_of_band_connection, path: "out_of_band_connection", type: "out_of_band_connections",
                                               accepts: %i[port ssh_key_id]
        action :list_out_of_band_connections,  path: "out_of_band_connection", method: :get

        class << self
          def deploy_config(id, opts = {}, path_params: {})
            params = opts.is_a?(Hash) ? opts : {}
            path_params = extract_path_params(params, path_param_keys) if path_params.empty?
            parsed = execute_request(
              method: :get,
              path: "#{instance_url(id, path_params: path_params)}/deploy_config",
              opts: params,
            )
            parsed
          end

          def update_deploy_config(id, attributes = {}, opts = {})
            body = JSONAPI.encode(type: "deploy_config", id: id, attributes: attributes)
            parsed = execute_request(
              method: :patch,
              path: "#{instance_url(id)}/deploy_config",
              body: body,
              opts: opts,
            )
            parsed
          end
        end

        def deploy_config(opts = {})
          self.class.deploy_config(id, opts)
        end

        def update_deploy_config(attributes, opts = {})
          self.class.update_deploy_config(id, attributes, opts)
        end
      end
    end
  end
end
