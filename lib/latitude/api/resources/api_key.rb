# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] token
      #   @return [String]
      # @!attribute [rw] token_last_slice
      #   @return [String]
      # @!attribute [rw] api_version
      #   @return [String]
      # @!attribute [rw] read_only
      #   @return [Boolean]
      # @!attribute [rw] allowed_ips
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] last_used_at
      #   @return [Time]
      # @!attribute [rw] user
      #   @return [Latitude::API::Objects::User]
      class APIKey < APIResource
        attribute :name, :string
        attribute :token, :string
        attribute :token_last_slice, :string
        attribute :api_version, :string
        attribute :read_only, :boolean
        attribute :allowed_ips, :string
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :last_used_at, :time
        attribute :user, Objects::User

        resource_type "api_keys"
        resource_path "/auth/api_keys"
        id_prefix     "tok_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Update
        extend Operations::Delete

        class << self
          def rotate(id, params = {}, opts = {})
            body = JSONAPI.encode(type: resource_type, id: id, attributes: params)
            parsed = execute_request(method: :put, path: instance_url(id), body: body, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end

        def rotate(params = {}, opts = {})
          self.class.rotate(id, params, opts)
        end
      end
    end
  end
end
