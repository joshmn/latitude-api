# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] content
      #   @return [String]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] decoded_content
      #   @return [String]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      class UserData < APIResource
        attribute :description, :string
        attribute :content, :string
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :decoded_content, :string
        attribute :project, Objects::Project

        resource_type "user_data"
        resource_path "/user_data"
        id_prefix     "ud_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
      end
    end
  end
end
