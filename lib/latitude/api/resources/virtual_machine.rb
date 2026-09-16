# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] status
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] primary_ipv4
      #   @return [String]
      # @!attribute [rw] operating_system
      #   @return [OperatingSystem]
      # @!attribute [rw] site
      #   @return [String]
      # @!attribute [rw] billing
      #   @return [String]
      # @!attribute [rw] plan
      #   @return [Plan]
      # @!attribute [rw] specs
      #   @return [Spec]
      # @!attribute [rw] team
      #   @return [Latitude::API::Objects::Team]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] credentials
      #   @return [Credential]
      class VirtualMachine < APIResource
          # @!attribute [r] raid
          #   @return [Boolean]
          # @!attribute [r] ssh_keys
          #   @return [Boolean]
          # @!attribute [r] user_data
          #   @return [Boolean]
        class Feature < APIObject
          attribute :raid, :boolean, read_only: true
          attribute :ssh_keys, :boolean, read_only: true
          attribute :user_data, :boolean, read_only: true
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

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
        class Plan < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
        end

          # @!attribute [r] vcpu
          #   @return [Integer]
          # @!attribute [r] ram
          #   @return [String]
          # @!attribute [r] storage
          #   @return [String]
          # @!attribute [r] nic
          #   @return [String]
          # @!attribute [r] gpu
          #   @return [String]
        class Spec < APIObject
          attribute :vcpu, :integer, read_only: true
          attribute :ram, :string, read_only: true
          attribute :storage, :string, read_only: true
          attribute :nic, :string, read_only: true
          attribute :gpu, :string, read_only: true
        end

          # @!attribute [r] username
          #   @return [String]
          # @!attribute [r] host
          #   @return [String]
          # @!attribute [r] password
          #   @return [String]
          # @!attribute [r] ssh_keys
          #   @return [Array]
        class Credential < APIObject
          attribute :username, :string, read_only: true
          attribute :host, :string, read_only: true
          attribute :password, :string, read_only: true
          attribute :ssh_keys, :array, read_only: true
        end

        attribute :name, :string
        attribute :status, :string
        attribute :created_at, :time, read_only: true
        attribute :primary_ipv4, :string
        attribute :operating_system, OperatingSystem
        attribute :site, :string
        attribute :billing, :string
        attribute :plan, Plan
        attribute :specs, Spec
        attribute :team, Objects::Team
        attribute :project, Objects::Project
        attribute :credentials, Credential

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
