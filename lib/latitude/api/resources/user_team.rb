# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] slug
      #   @return [String]
      # @!attribute [rw] address
      #   @return [String]
      # @!attribute [rw] currency
      #   @return [String]
      # @!attribute [rw] enforce_mfa
      #   @return [Boolean]
      # @!attribute [rw] referred_code
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] status
      #   @return [String]
      # @!attribute [rw] users
      #   @return [Array<User>]
      # @!attribute [rw] projects
      #   @return [Array]
      # @!attribute [rw] owner
      #   @return [Latitude::API::Objects::User]
      # @!attribute [rw] billing
      #   @return [Latitude::API::Objects::Billing]
      # @!attribute [rw] feature_flags
      #   @return [Array]
      # @!attribute [rw] limits
      #   @return [Latitude::API::Objects::Limits]
      # @!attribute [rw] token
      #   @return [String]
      # @!attribute [rw] customer_billing_id
      #   @return [String]
      class UserTeam < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] first_name
          #   @return [String]
          # @!attribute [r] last_name
          #   @return [String]
          # @!attribute [r] email
          #   @return [String]
          # @!attribute [r] created_at
          #   @return [Time]
          # @!attribute [r] updated_at
          #   @return [Time]
          # @!attribute [r] role
          #   @return [Latitude::API::Objects::Role]
        class User < APIObject
          attribute :id, :string, read_only: true
          attribute :first_name, :string, read_only: true
          attribute :last_name, :string, read_only: true
          attribute :email, :string, read_only: true
          attribute :created_at, :time, read_only: true
          attribute :updated_at, :time, read_only: true
          attribute :role, Objects::Role, read_only: true
        end

        attribute :name, :string
        attribute :slug, :string
        attribute :address, :string
        attribute :currency, :string
        attribute :enforce_mfa, :boolean
        attribute :referred_code, :string
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :status, :string
        attribute :users, [User]
        attribute :projects, :array
        attribute :owner, Objects::User
        attribute :billing, Objects::Billing
        attribute :feature_flags, :array
        attribute :limits, Objects::Limits
        attribute :token, :string
        attribute :customer_billing_id, :string

        resource_type "teams"
        resource_path "/user/teams"

        extend Operations::List
      end
    end
  end
end
