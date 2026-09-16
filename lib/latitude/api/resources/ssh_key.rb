# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] tags
      #   @return [Array<Latitude::API::Objects::Tag>]
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] public_key
      #   @return [String]
      # @!attribute [rw] fingerprint
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] user
      #   @return [Latitude::API::Objects::User]
      class SSHKey < APIResource
        attribute :tags, [Objects::Tag]
        attribute :name, :string
        attribute :public_key, :string
        attribute :fingerprint, :string
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :project, Objects::Project
        attribute :user, Objects::User

        resource_type "ssh_keys"
        resource_path "/ssh_keys"
        id_prefix     "ssh_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
      end
    end
  end
end
