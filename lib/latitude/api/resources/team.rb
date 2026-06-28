# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Team < APIResource
        resource_type "teams"
        resource_path "/team"
        id_prefix     "team_"

        extend Operations::Create
        extend Operations::Update

        class << self
          def retrieve(opts = {})
            parsed = execute_request(method: :get, path: resource_path, opts: opts)
            construct_from(parsed, opts: opts)
          end

          def members
            Member
          end
        end

        class Member < APIResource
          resource_type "memberships"
          resource_path "/team/members"
          id_prefix     "user_"

          extend Operations::List
          extend Operations::Delete

          class << self
            def create(params = {}, opts = {})
              body = JSONAPI.encode(type: "teams", attributes: params)
              parsed = execute_request(method: :post, path: resource_path, body: body, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
