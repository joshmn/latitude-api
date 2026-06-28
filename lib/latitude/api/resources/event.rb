# frozen_string_literal: true

module Latitude
  module API
    module Resources
      class Event < APIResource
        resource_type "events"
        resource_path "/events"
        id_prefix     "evt_"

        extend Operations::List
      end
    end
  end
end
