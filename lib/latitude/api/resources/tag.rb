# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] slug
      #   @return [String]
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] color
      #   @return [String]
      # @!attribute [rw] team
      #   @return [Latitude::API::Objects::Team]
      class Tag < APIResource
        attribute :name, :string
        attribute :slug, :string
        attribute :description, :string
        attribute :color, :string
        attribute :team, Objects::Team

        resource_type "tags"
        resource_path "/tags"
        id_prefix     "tag_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Update
        extend Operations::Delete
      end
    end
  end
end
