# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Region < APIResource
        resource_type "regions"
        resource_path "/regions"
        id_prefix     "reg_"

        extend Operations::List
        extend Operations::Retrieve
      end
    end
  end
end
