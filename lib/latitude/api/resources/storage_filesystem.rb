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
        # @!attribute [rw] project
        #   @return [Latitude::API::Objects::Project]
        # @!attribute [rw] team
        #   @return [Latitude::API::Objects::Team]
        class Filesystem < APIResource
          attribute :name, :string
          attribute :size_in_gb, :integer
          attribute :created_at, :time, read_only: true
          attribute :project, Objects::Project
          attribute :team, Objects::Team

          resource_type "filesystems"
          resource_path "/storage/filesystems"
          id_prefix     "fs_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Update
          extend Operations::Delete
        end
      end
    end
  end
end
