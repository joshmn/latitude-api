# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] phase
      #   @return [String]
      # @!attribute [rw] ready
      #   @return [Boolean]
      # @!attribute [rw] control_plane_endpoint
      #   @return [String]
      # @!attribute [rw] kubeconfig_url
      #   @return [String]
      # @!attribute [rw] location
      #   @return [String]
      # @!attribute [rw] load_balancer_ips
      #   @return [Array]
      # @!attribute [rw] kubernetes_version
      #   @return [String]
      # @!attribute [rw] version_status
      #   @return [String]
      # @!attribute [rw] available_upgrade
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] plan
      #   @return [String]
      # @!attribute [rw] worker_plan
      #   @return [String]
      # @!attribute [rw] control_plane_count
      #   @return [Integer]
      # @!attribute [rw] worker_count
      #   @return [Integer]
      # @!attribute [rw] control_plane
      #   @return [ControlPlane]
      # @!attribute [rw] workers
      #   @return [Worker]
      # @!attribute [rw] worker_status
      #   @return [String]
      # @!attribute [rw] control_plane_status
      #   @return [String]
      # @!attribute [rw] infrastructure_ready
      #   @return [Boolean]
      # @!attribute [rw] control_plane_ready
      #   @return [Boolean]
      # @!attribute [rw] message
      #   @return [String]
      # @!attribute [rw] steps
      #   @return [Array<Step>]
      # @!attribute [rw] last_status_change
      #   @return [Time]
      # @!attribute [rw] failure_message
      #   @return [String]
      # @!attribute [rw] failure_reason
      #   @return [String]
      # @!attribute [rw] nodes
      #   @return [Array<Node>]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] status
      #   @return [String]
      class KubernetesCluster < APIResource
          # @!attribute [r] ready
          #   @return [Boolean]
          # @!attribute [r] replicas
          #   @return [Integer]
          # @!attribute [r] ready_replicas
          #   @return [Integer]
        class ControlPlane < APIObject
          attribute :ready, :boolean, read_only: true
          attribute :replicas, :integer, read_only: true
          attribute :ready_replicas, :integer, read_only: true
        end

          # @!attribute [r] replicas
          #   @return [Integer]
          # @!attribute [r] ready_replicas
          #   @return [Integer]
          # @!attribute [r] available_replicas
          #   @return [Integer]
        class Worker < APIObject
          attribute :replicas, :integer, read_only: true
          attribute :ready_replicas, :integer, read_only: true
          attribute :available_replicas, :integer, read_only: true
        end

          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] status
          #   @return [String]
        class Step < APIObject
          attribute :name, :string, read_only: true
          attribute :status, :string, read_only: true
        end

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] hostname
          #   @return [String]
          # @!attribute [r] server_id
          #   @return [String]
          # @!attribute [r] type
          #   @return [String]
          # @!attribute [r] status
          #   @return [String]
          # @!attribute [r] ip
          #   @return [String]
          # @!attribute [r] internal_ip
          #   @return [String]
          # @!attribute [r] external_ip
          #   @return [String]
        class Node < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :hostname, :string, read_only: true
          attribute :server_id, :string, read_only: true
          attribute :type, :string, read_only: true
          attribute :status, :string, read_only: true
          attribute :ip, :string, read_only: true
          attribute :internal_ip, :string, read_only: true
          attribute :external_ip, :string, read_only: true
        end

        attribute :name, :string
        attribute :phase, :string
        attribute :ready, :boolean
        attribute :control_plane_endpoint, :string
        attribute :kubeconfig_url, :string
        attribute :location, :string
        attribute :load_balancer_ips, :array
        attribute :kubernetes_version, :string
        attribute :version_status, :string
        attribute :available_upgrade, :string
        attribute :created_at, :time, read_only: true
        attribute :plan, :string
        attribute :worker_plan, :string
        attribute :control_plane_count, :integer
        attribute :worker_count, :integer
        attribute :control_plane, ControlPlane
        attribute :workers, Worker
        attribute :worker_status, :string
        attribute :control_plane_status, :string
        attribute :infrastructure_ready, :boolean
        attribute :control_plane_ready, :boolean
        attribute :message, :string
        attribute :steps, [Step]
        attribute :last_status_change, :time
        attribute :failure_message, :string
        attribute :failure_reason, :string
        attribute :nodes, [Node]
        attribute :project, Objects::Project
        attribute :status, :string

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
