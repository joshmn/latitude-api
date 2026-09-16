# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] tags
      #   @return [Array<Latitude::API::Objects::Tag>]
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] slug
      #   @return [String]
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] bandwidth_alert
      #   @return [Boolean]
      # @!attribute [rw] environment
      #   @return [String]
      # @!attribute [rw] provisioning_type
      #   @return [String]
      # @!attribute [rw] billing_type
      #   @return [String]
      # @!attribute [rw] billing_method
      #   @return [String]
      # @!attribute [rw] billing
      #   @return [Latitude::API::Objects::Billing]
      # @!attribute [rw] team
      #   @return [Latitude::API::Objects::Team]
      # @!attribute [rw] stats
      #   @return [Latitude::API::Objects::Stats]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      # @!attribute [rw] cost
      #   @return [String]
      class Project < APIResource
        attribute :tags, [Objects::Tag]
        attribute :name, :string
        attribute :slug, :string
        attribute :description, :string
        attribute :bandwidth_alert, :boolean
        attribute :environment, :string
        attribute :provisioning_type, :string
        attribute :billing_type, :string
        attribute :billing_method, :string
        attribute :billing, Objects::Billing
        attribute :team, Objects::Team
        attribute :stats, Objects::Stats
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true
        attribute :cost, :string

        resource_type "projects"
        resource_path "/projects"
        id_prefix     "proj_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
        extend Operations::Nested

        nested_resource :ssh_keys,  class_name: "Latitude::API::Resources::Project::SSHKey"
        nested_resource :user_data, class_name: "Latitude::API::Resources::Project::UserData"

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
          resource_path "/projects/:project_id/ssh_keys"
          id_prefix     "ssh_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Retrieve
          extend Operations::Update
          extend Operations::Delete
        end

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
          resource_path "/projects/:project_id/user_data"
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
end
