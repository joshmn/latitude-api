# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      class Role < APIResource
        attribute :name, :string

        resource_type "roles"
        resource_path "/roles"
        id_prefix     "role_"

        extend Operations::List
        extend Operations::Retrieve
      end
    end
  end
end
