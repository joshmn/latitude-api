# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class UserData < APIResource
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
