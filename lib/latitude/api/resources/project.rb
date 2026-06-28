# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Project < APIResource
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

        class SSHKey < APIResource
          resource_type "ssh_keys"
          resource_path "/projects/:project_id/ssh_keys"
          id_prefix     "ssh_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Retrieve
          extend Operations::Update
          extend Operations::Delete
        end

        class UserData < APIResource
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
