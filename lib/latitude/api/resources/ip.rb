# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class IP < APIResource
        resource_type "ip_addresses"
        resource_path "/ips"
        id_prefix     "ip_"

        extend Operations::List
        extend Operations::Retrieve
      end
    end
  end
end
