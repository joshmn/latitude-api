# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] rules
      #   @return [Array<Rule>]
      class Firewall < APIResource
          # @!attribute [r] from
          #   @return [String]
          # @!attribute [r] to
          #   @return [String]
          # @!attribute [r] port
          #   @return [String]
          # @!attribute [r] protocol
          #   @return [String]
          # @!attribute [r] default
          #   @return [Boolean]
        class Rule < APIObject
          attribute :from, :string, read_only: true
          attribute :to, :string, read_only: true
          attribute :port, :string, read_only: true
          attribute :protocol, :string, read_only: true
          attribute :default, :boolean, read_only: true
        end

        attribute :name, :string
        attribute :project, Objects::Project
        attribute :rules, [Rule]

        resource_type "firewalls"
        resource_path "/firewalls"
        id_prefix     "firewall_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Retrieve
        extend Operations::Update
        extend Operations::Delete

        class << self
          def assignments
            Assignment
          end
        end

        # @!attribute [rw] server

        #   @return [Server]

        # @!attribute [rw] firewall

        #   @return [Firewall]

        # @!attribute [rw] firewall_id

        #   @return [String]

        class Assignment < APIResource

            # @!attribute [r] id

            #   @return [String]

            # @!attribute [r] hostname

            #   @return [String]

            # @!attribute [r] primary_ipv4

            #   @return [String]

          class Server < APIObject

            attribute :id, :string, read_only: true

            attribute :hostname, :string, read_only: true

            attribute :primary_ipv4, :string, read_only: true

          end


            # @!attribute [r] id

            #   @return [String]

            # @!attribute [r] name

            #   @return [String]

          class Firewall < APIObject

            attribute :id, :string, read_only: true

            attribute :name, :string, read_only: true

          end


          attribute :server, Server

          attribute :firewall, Firewall

          attribute :firewall_id, :string

          resource_type "firewall_assignments"
          resource_path "/firewalls/:firewall_id/assignments"

          extend Operations::List
          extend Operations::Create
          extend Operations::Delete

          class << self
            def list_all(params = {}, opts = {})
              query = RequestParams.encode(params)
              parsed = execute_request(method: :get, path: "/firewalls/assignments", query: query, opts: opts)
              ListObject.new(resource_class: self, parsed: parsed, request_params: params, request_opts: opts)
            end
          end
        end
      end
    end
  end
end
