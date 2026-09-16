# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] address
      #   @return [String]
      # @!attribute [rw] family
      #   @return [String]
      # @!attribute [rw] prefix_length
      #   @return [Integer]
      # @!attribute [rw] mode
      #   @return [String]
      # @!attribute [rw] status
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] server
      #   @return [Server]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] region
      #   @return [Region]
      class ElasticIP < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] hostname
          #   @return [String]
          # @!attribute [r] primary_ipv4
          #   @return [String]
          # @!attribute [r] operating_system
          #   @return [String]
        class Server < APIObject
          attribute :id, :string, read_only: true
          attribute :hostname, :string, read_only: true
          attribute :primary_ipv4, :string, read_only: true
          attribute :operating_system, :string, read_only: true
        end

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

        attribute :address, :string
        attribute :family, :string
        attribute :prefix_length, :integer
        attribute :mode, :string
        attribute :status, :string
        attribute :created_at, :time, read_only: true
        attribute :server, Server
        attribute :project, Objects::Project
        attribute :region, Region

        resource_type "elastic_ips"
        resource_path "/elastic_ips"
        id_prefix     "eip_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class << self
          def move(id, server_id:, opts: {})
            update(id, { server_id: server_id }, opts)
          end
        end

        def move_to(server_id, opts = {})
          self.class.move(id, server_id: server_id, opts: opts)
        end
      end
    end
  end
end
