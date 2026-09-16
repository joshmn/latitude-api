# frozen_string_literal: true

module Latitude
  module API
    # Shared, read-only value objects that appear as nested attributes across
    # many resources (project/team/currency/limits/stats/billing/tag/user/role).
    module Objects
      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] code
      #   @return [String]
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] currency_id
      #   @return [String]
      class Currency < APIObject
        attribute :id, :string, read_only: true
        attribute :code, :string, read_only: true
        attribute :name, :string, read_only: true
        attribute :currency_id, :string, read_only: true
      end

      # @!attribute [r] bare_metal
      #   @return [Integer]
      # @!attribute [r] bare_metal_gpu
      #   @return [Integer]
      # @!attribute [r] virtual_machine
      #   @return [Integer]
      # @!attribute [r] virtual_machine_gpu
      #   @return [Integer]
      # @!attribute [r] elastic_ip
      #   @return [Integer]
      # @!attribute [r] virtual_network
      #   @return [Integer]
      # @!attribute [r] database
      #   @return [String]
      # @!attribute [r] filesystem
      #   @return [String]
      # @!attribute [r] block_storage
      #   @return [String]
      class Limits < APIObject
        attribute :bare_metal, :integer, read_only: true
        attribute :bare_metal_gpu, :integer, read_only: true
        attribute :virtual_machine, :integer, read_only: true
        attribute :virtual_machine_gpu, :integer, read_only: true
        attribute :elastic_ip, :integer, read_only: true
        attribute :virtual_network, :integer, read_only: true
        attribute :database, :string, read_only: true
        attribute :filesystem, :string, read_only: true
        attribute :block_storage, :string, read_only: true
      end

      # @!attribute [r] databases
      #   @return [Integer]
      # @!attribute [r] ip_addresses
      #   @return [Integer]
      # @!attribute [r] prefixes
      #   @return [Integer]
      # @!attribute [r] servers
      #   @return [Integer]
      # @!attribute [r] storages
      #   @return [Integer]
      # @!attribute [r] virtual_machines
      #   @return [Integer]
      # @!attribute [r] vlans
      #   @return [Integer]
      class Stats < APIObject
        attribute :databases, :integer, read_only: true
        attribute :ip_addresses, :integer, read_only: true
        attribute :prefixes, :integer, read_only: true
        attribute :servers, :integer, read_only: true
        attribute :storages, :integer, read_only: true
        attribute :virtual_machines, :integer, read_only: true
        attribute :vlans, :integer, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] customer_billing_id
      #   @return [String]
      # @!attribute [r] subscription_id
      #   @return [String]
      # @!attribute [r] type
      #   @return [String]
      # @!attribute [r] method
      #   @return [String]
      class Billing < APIObject
        attribute :id, :string, read_only: true
        attribute :customer_billing_id, :string, read_only: true
        attribute :subscription_id, :string, read_only: true
        attribute :type, :string, read_only: true
        attribute :method, :string, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      class Role < APIObject
        attribute :id, :string, read_only: true
        attribute :name, :string, read_only: true
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] description
      #   @return [String]
      # @!attribute [r] color
      #   @return [String]
      class Tag < APIObject
        attribute :id, :string, read_only: true
        attribute :name, :string, read_only: true
        attribute :description, :string, read_only: true
        attribute :color, :string, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] slug
      #   @return [String]
      # @!attribute [r] description
      #   @return [String]
      # @!attribute [r] address
      #   @return [String]
      # @!attribute [r] currency
      #   @return [Latitude::API::Objects::Currency]
      # @!attribute [r] status
      #   @return [String]
      # @!attribute [r] feature_flags
      #   @return [Array]
      # @!attribute [r] limits
      #   @return [Latitude::API::Objects::Limits]
      class Team < APIObject
        attribute :id, :string, read_only: true
        attribute :name, :string, read_only: true
        attribute :slug, :string, read_only: true
        attribute :description, :string, read_only: true
        attribute :address, :string, read_only: true
        attribute :currency, Objects::Currency, read_only: true
        attribute :status, :string, read_only: true
        attribute :feature_flags, :array, read_only: true
        attribute :limits, Objects::Limits, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] slug
      #   @return [String]
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] description
      #   @return [String]
      # @!attribute [r] provisioning_type
      #   @return [String]
      # @!attribute [r] billing_type
      #   @return [String]
      # @!attribute [r] billing_method
      #   @return [String]
      # @!attribute [r] bandwidth_alert
      #   @return [Boolean]
      # @!attribute [r] environment
      #   @return [String]
      # @!attribute [r] billing
      #   @return [Latitude::API::Objects::Billing]
      # @!attribute [r] stats
      #   @return [Latitude::API::Objects::Stats]
      class Project < APIObject
        attribute :id, :string, read_only: true
        attribute :slug, :string, read_only: true
        attribute :name, :string, read_only: true
        attribute :description, :string, read_only: true
        attribute :provisioning_type, :string, read_only: true
        attribute :billing_type, :string, read_only: true
        attribute :billing_method, :string, read_only: true
        attribute :bandwidth_alert, :boolean, read_only: true
        attribute :environment, :string, read_only: true
        attribute :billing, Objects::Billing, read_only: true
        attribute :stats, Objects::Stats, read_only: true
      end

      # @!attribute [r] id
      #   @return [String]
      # @!attribute [r] email
      #   @return [String]
      # @!attribute [r] first_name
      #   @return [String]
      # @!attribute [r] last_name
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [r] role
      #   @return [Latitude::API::Objects::Role]
      class User < APIObject
        attribute :id, :string, read_only: true
        attribute :email, :string, read_only: true
        attribute :first_name, :string, read_only: true
        attribute :last_name, :string, read_only: true
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :role, Objects::Role, read_only: true
      end
    end
  end
end
