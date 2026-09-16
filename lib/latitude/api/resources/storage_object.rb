# frozen_string_literal: true

module Latitude
  module API
    module Resources
      module Storage
        # @!attribute [rw] name
        #   @return [String]
        # @!attribute [rw] storage_type
        #   @return [String]
        # @!attribute [rw] storage_class
        #   @return [String]
        # @!attribute [r] created_at
        #   @return [Time]
        # @!attribute [rw] bucket_name
        #   @return [String]
        # @!attribute [rw] endpoint
        #   @return [String]
        # @!attribute [rw] access_key
        #   @return [String]
        # @!attribute [rw] secret_key
        #   @return [String]
        # @!attribute [rw] versioning
        #   @return [Boolean]
        # @!attribute [rw] locking
        #   @return [Boolean]
        # @!attribute [rw] retention_mode
        #   @return [String]
        # @!attribute [rw] retention_period
        #   @return [String]
        # @!attribute [rw] region
        #   @return [Region]
        # @!attribute [rw] project
        #   @return [Latitude::API::Objects::Project]
        # @!attribute [rw] team
        #   @return [Latitude::API::Objects::Team]
        class Object < APIResource
            # @!attribute [r] id
            #   @return [String]
            # @!attribute [r] city
            #   @return [String]
            # @!attribute [r] country
            #   @return [String]
          class Region < APIObject
            attribute :id, :string, read_only: true
            attribute :city, :string, read_only: true
            attribute :country, :string, read_only: true
          end

          attribute :name, :string
          attribute :storage_type, :string
          attribute :storage_class, :string
          attribute :created_at, :time, read_only: true
          attribute :bucket_name, :string
          attribute :endpoint, :string
          attribute :access_key, :string
          attribute :secret_key, :string
          attribute :versioning, :boolean
          attribute :locking, :boolean
          attribute :retention_mode, :string
          attribute :retention_period, :string
          attribute :region, Region
          attribute :project, Objects::Project
          attribute :team, Objects::Team

          resource_type "object_storages"
          resource_path "/storage/objects"
          id_prefix     "objs_"

          extend Operations::List
          extend Operations::Retrieve
          extend Operations::Delete

          class << self
            def create(params = {}, opts = {})
              body = JSONAPI.encode(type: "objects", attributes: params)
              parsed = execute_request(method: :post, path: resource_path, body: body, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
