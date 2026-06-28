# frozen_string_literal: true

module Latitude
  module API
    module Resources
      module Storage
        class Filesystem < APIResource
          resource_type "filesystems"
          resource_path "/storage/filesystems"
          id_prefix     "fs_"

          extend Operations::List
          extend Operations::Create
          extend Operations::Update
          extend Operations::Delete
        end
      end
    end
  end
end
