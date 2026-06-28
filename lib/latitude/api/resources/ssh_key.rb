# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class SSHKey < APIResource
        resource_type "ssh_keys"
        resource_path "/ssh_keys"
        id_prefix     "ssh_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete
      end
    end
  end
end
