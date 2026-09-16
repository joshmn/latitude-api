# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] first_name
      #   @return [String]
      # @!attribute [rw] last_name
      #   @return [String]
      # @!attribute [rw] email
      #   @return [String]
      # @!attribute [rw] mfa_enabled
      #   @return [Boolean]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] last_login_at
      #   @return [Time]
      # @!attribute [rw] role
      #   @return [Latitude::API::Objects::Role]
      class UserProfile < SingletonAPIResource
        attribute :first_name, :string
        attribute :last_name, :string
        attribute :email, :string
        attribute :mfa_enabled, :boolean
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :last_login_at, :time
        attribute :role, Objects::Role

        resource_type "users"
        resource_path "/user/profile"

        class << self
          def retrieve(opts = {})
            parsed = execute_request(method: :get, path: resource_path, opts: opts)
            construct_from(parsed, opts: opts)
          end

          def update(id, params = {}, opts = {})
            body = JSONAPI.encode(type: resource_type, id: id, attributes: params)
            parsed = execute_request(method: :patch, path: "#{resource_path}/#{URI.encode_www_form_component(id)}",
                                     body: body, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end
      end
    end
  end
end
