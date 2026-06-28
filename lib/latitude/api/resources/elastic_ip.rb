# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class ElasticIP < APIResource
        resource_type "elastic_ips"
        resource_path "/elastic_ips"
        id_prefix     "eip_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class << self
          def move(id, server_id:, opts: {})
            update(id, { server_id: server_id }, opts)
          end
        end

        def move_to(server_id, opts = {})
          self.class.move(id, server_id: server_id, opts: opts)
        end
      end
    end
  end
end
