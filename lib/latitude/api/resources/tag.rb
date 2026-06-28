# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Tag < APIResource
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
