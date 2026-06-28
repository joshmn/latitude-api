# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class KubernetesCluster < APIResource
        resource_type "kubernetes_clusters"
        resource_path "/kubernetes_clusters"
        id_prefix     "kc_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class << self
          def available_versions(opts = {})
            execute_request(method: :get, path: "#{resource_path}/available_versions", opts: opts)
          end

          def kubeconfig(id, opts = {})
            execute_request(method: :get, path: "#{instance_url(id)}/kubeconfig", opts: opts)
          end
        end

        def kubeconfig(opts = {})
          self.class.kubeconfig(id, opts)
        end
      end
    end
  end
end
