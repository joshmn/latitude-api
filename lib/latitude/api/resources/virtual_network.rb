# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] tags
      #   @return [Array<Latitude::API::Objects::Tag>]
      # @!attribute [rw] vid
      #   @return [Integer]
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] site
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] region
      #   @return [Region]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] assignments_count
      #   @return [Integer]
      class VirtualNetwork < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] facility
          #   @return [String]
        class Site < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :facility, :string, read_only: true
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

        attribute :tags, [Objects::Tag]
        attribute :vid, :integer
        attribute :name, :string
        attribute :description, :string
        attribute :site, :string
        attribute :created_at, :time, read_only: true
        attribute :region, Region
        attribute :project, Objects::Project
        attribute :assignments_count, :integer

        resource_type "virtual_networks"
        resource_path "/virtual_networks"
        id_prefix     "vlan_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        # @!attribute [rw] virtual_network_id

        #   @return [String]

        # @!attribute [rw] vid

        #   @return [Integer]

        # @!attribute [rw] description

        #   @return [String]

        # @!attribute [rw] status

        #   @return [String]

        # @!attribute [rw] server

        #   @return [Server]

        # @!attribute [rw] server_id

        #   @return [String]

        class Assignment < APIResource

            # @!attribute [r] id

            #   @return [String]

            # @!attribute [r] hostname

            #   @return [String]

            # @!attribute [r] label

            #   @return [String]

            # @!attribute [r] locked

            #   @return [Boolean]

            # @!attribute [r] status

            #   @return [String]

          class Server < APIObject

            attribute :id, :string, read_only: true

            attribute :hostname, :string, read_only: true

            attribute :label, :string, read_only: true

            attribute :locked, :boolean, read_only: true

            attribute :status, :string, read_only: true

          end


          attribute :virtual_network_id, :string

          attribute :vid, :integer

          attribute :description, :string

          attribute :status, :string

          attribute :server, Server

          attribute :server_id, :string

          resource_type "virtual_network_assignment"
          resource_path "/virtual_networks/assignments"

          extend Operations::List
          extend Operations::Delete

          class << self
            def create(params = {}, opts = {})
              body = JSONAPI.encode(type: resource_type, attributes: params)
              parsed = execute_request(method: :post, path: resource_path, body: body, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
