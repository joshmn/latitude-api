# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class VPNSession < APIResource
        resource_type "vpn_sessions"
        resource_path "/vpn_sessions"
        id_prefix     "vpn_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Delete

        class << self
          def refresh_password(id, opts = {})
            parsed = execute_request(method: :patch, path: "#{instance_url(id)}/refresh_password", opts: opts)
            construct_from(parsed, opts: opts)
          end
        end

        def refresh_password(opts = {})
          self.class.refresh_password(id, opts)
        end
      end
    end
  end
end
