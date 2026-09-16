# frozen_string_literal: true

module Latitude
  module API
    module Resources
      module Storage
        # @!attribute [rw] name
        #   @return [String]
        # @!attribute [rw] size_in_gb
        #   @return [Integer]
        # @!attribute [r] created_at
        #   @return [Time]
        # @!attribute [rw] namespace_id
        #   @return [String]
        # @!attribute [rw] connector_id
        #   @return [String]
        # @!attribute [rw] initiators
        #   @return [Array<Initiator>]
        # @!attribute [rw] project
        #   @return [Latitude::API::Objects::Project]
        # @!attribute [rw] team
        #   @return [Latitude::API::Objects::Team]
        class Volume < APIResource
            # @!attribute [r] nqn
            #   @return [String]
          class Initiator < APIObject
            attribute :nqn, :string, read_only: true
          end

          attribute :name, :string
          attribute :size_in_gb, :integer
          attribute :created_at, :time, read_only: true
          attribute :namespace_id, :string
          attribute :connector_id, :string
          attribute :initiators, [Initiator]
          attribute :project, Objects::Project
          attribute :team, Objects::Team

          resource_type "volumes"
          resource_path "/storage/volumes"
          id_prefix     "vol_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Retrieve
          extend Operations::Delete

          class << self
            def mount(id, server_id: nil, opts: {})
              attrs = { server_id: server_id }.compact
              body = JSONAPI.encode(type: "volumes", attributes: attrs)
              parsed = execute_request(method: :post, path: "#{instance_url(id)}/mount", body: body, opts: opts)
              parsed
            end
          end

          def mount(server_id: nil, opts: {})
            self.class.mount(id, server_id: server_id, opts: opts)
          end
        end
      end
    end
  end
end
