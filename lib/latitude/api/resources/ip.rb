# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] address
      #   @return [String]
      # @!attribute [rw] cidr
      #   @return [String]
      # @!attribute [rw] family
      #   @return [String]
      # @!attribute [rw] gateway
      #   @return [String]
      # @!attribute [rw] netmask
      #   @return [String]
      # @!attribute [rw] type
      #   @return [String]
      # @!attribute [rw] public
      #   @return [Boolean]
      # @!attribute [rw] management
      #   @return [Boolean]
      # @!attribute [rw] additional
      #   @return [Boolean]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] region
      #   @return [Region]
      # @!attribute [rw] available
      #   @return [Boolean]
      # @!attribute [rw] assignment
      #   @return [Assignment]
      # @!attribute [rw] elastic
      #   @return [Elastic]
      # @!attribute [r] created_at
      #   @return [Time]
      class IP < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
        class Location < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
        end

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] location
          #   @return [Location]
        class Region < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :location, Location, read_only: true
        end

          # @!attribute [r] server_id
          #   @return [String]
          # @!attribute [r] hostname
          #   @return [String]
          # @!attribute [r] assigned_at
          #   @return [String]
        class Assignment < APIObject
          attribute :server_id, :string, read_only: true
          attribute :hostname, :string, read_only: true
          attribute :assigned_at, :string, read_only: true
        end

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] mode
          #   @return [String]
          # @!attribute [r] status
          #   @return [String]
        class Elastic < APIObject
          attribute :id, :string, read_only: true
          attribute :mode, :string, read_only: true
          attribute :status, :string, read_only: true
        end

        attribute :address, :string
        attribute :cidr, :string
        attribute :family, :string
        attribute :gateway, :string
        attribute :netmask, :string
        attribute :type, :string
        attribute :public, :boolean
        attribute :management, :boolean
        attribute :additional, :boolean
        attribute :project, Objects::Project
        attribute :region, Region
        attribute :available, :boolean
        attribute :assignment, Assignment
        attribute :elastic, Elastic
        attribute :created_at, :time, read_only: true

        resource_type "ip_addresses"
        resource_path "/ips"
        id_prefix     "ip_"

        extend Operations::List
        extend Operations::Retrieve
      end
    end
  end
end
