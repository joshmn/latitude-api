# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [rw] action
      #   @return [String]
      # @!attribute [rw] target
      #   @return [Target]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] team
      #   @return [Latitude::API::Objects::Team]
      # @!attribute [rw] author
      #   @return [Author]
      class Event < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
        class Target < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
        end

          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] email
          #   @return [String]
        class Author < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :email, :string, read_only: true
        end

        attribute :created_at, :time, read_only: true
        attribute :action, :string
        attribute :target, Target
        attribute :project, Objects::Project
        attribute :team, Objects::Team
        attribute :author, Author

        resource_type "events"
        resource_path "/events"
        id_prefix     "evt_"

        extend Operations::List
      end
    end
  end
end
