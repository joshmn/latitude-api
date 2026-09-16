# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] hostname
      #   @return [String]
      # @!attribute [rw] label
      #   @return [String]
      # @!attribute [rw] price
      #   @return [Integer]
      # @!attribute [rw] ipmi_status
      #   @return [String]
      # @!attribute [rw] scheduled_deletion_at
      #   @return [Time]
      # @!attribute [rw] status
      #   @return [String]
      # @!attribute [rw] role
      #   @return [String]
      # @!attribute [rw] primary_ipv4
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] locked
      #   @return [Boolean]
      # @!attribute [rw] team
      #   @return [Latitude::API::Objects::Team]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] region
      #   @return [Region]
      # @!attribute [rw] tags
      #   @return [Array<Latitude::API::Objects::Tag>]
      # @!attribute [rw] primary_ipv6
      #   @return [String]
      # @!attribute [rw] rescue_allowed
      #   @return [Boolean]
      # @!attribute [rw] plan
      #   @return [Plan]
      # @!attribute [rw] interfaces
      #   @return [Array<Interface>]
      # @!attribute [rw] operating_system
      #   @return [OperatingSystem]
      # @!attribute [rw] specs
      #   @return [Spec]
      class Server < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] facility
          #   @return [String]
          # @!attribute [r] rack_id
          #   @return [String]
        class Site < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :facility, :string, read_only: true
          attribute :rack_id, :string, read_only: true
        end

          # @!attribute [r] city
          #   @return [String]
          # @!attribute [r] country
          #   @return [String]
          # @!attribute [r] site
          #   @return [Site]
        class Region < APIObject
          attribute :city, :string, read_only: true
          attribute :country, :string, read_only: true
          attribute :site, Site, read_only: true
        end

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] billing
          #   @return [String]
        class Plan < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :billing, :string, read_only: true
        end

          # @!attribute [r] role
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] mac_address
          #   @return [String]
          # @!attribute [r] description
          #   @return [String]
        class Interface < APIObject
          attribute :role, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :mac_address, :string, read_only: true
          attribute :description, :string, read_only: true
        end

          # @!attribute [r] raid
          #   @return [Boolean]
          # @!attribute [r] ssh_keys
          #   @return [Boolean]
        class Feature < APIObject
          attribute :raid, :boolean, read_only: true
          attribute :ssh_keys, :boolean, read_only: true
        end

          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] series
          #   @return [String]
        class Distro < APIObject
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :series, :string, read_only: true
        end

          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] version
          #   @return [String]
          # @!attribute [r] features
          #   @return [Feature]
          # @!attribute [r] distro
          #   @return [Distro]
        class OperatingSystem < APIObject
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :version, :string, read_only: true
          attribute :features, Feature, read_only: true
          attribute :distro, Distro, read_only: true
        end

          # @!attribute [r] cpu
          #   @return [String]
          # @!attribute [r] disk
          #   @return [String]
          # @!attribute [r] ram
          #   @return [String]
          # @!attribute [r] nic
          #   @return [String]
          # @!attribute [r] gpu
          #   @return [String]
        class Spec < APIObject
          attribute :cpu, :string, read_only: true
          attribute :disk, :string, read_only: true
          attribute :ram, :string, read_only: true
          attribute :nic, :string, read_only: true
          attribute :gpu, :string, read_only: true
        end

        attribute :hostname, :string
        attribute :label, :string
        attribute :price, :integer
        attribute :ipmi_status, :string
        attribute :scheduled_deletion_at, :time
        attribute :status, :string
        attribute :role, :string
        attribute :primary_ipv4, :string
        attribute :created_at, :time, read_only: true
        attribute :locked, :boolean
        attribute :team, Objects::Team
        attribute :project, Objects::Project
        attribute :region, Region
        attribute :tags, [Objects::Tag]
        attribute :primary_ipv6, :string
        attribute :rescue_allowed, :boolean
        attribute :plan, Plan
        attribute :interfaces, [Interface]
        attribute :operating_system, OperatingSystem
        attribute :specs, Spec

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
