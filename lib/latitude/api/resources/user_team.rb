# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class UserTeam < APIResource
        resource_type "teams"
        resource_path "/user/teams"

        extend Operations::List
      end
    end
  end
end
