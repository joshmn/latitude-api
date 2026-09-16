# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] user_name
      #   @return [String]
      # @!attribute [rw] password
      #   @return [String]
      # @!attribute [rw] port
      #   @return [String]
      # @!attribute [rw] host
      #   @return [String]
      # @!attribute [rw] region
      #   @return [Region]
      # @!attribute [rw] expires_at
      #   @return [Time]
      # @!attribute [r] created_at
      #   @return [Time]
      # @!attribute [r] updated_at
      #   @return [Time]
      class VPNSession < APIResource
          # @!attribute [r] id
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
          # @!attribute [r] facility
          #   @return [String]
        class Site < APIObject
          attribute :id, :string, read_only: true
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
          attribute :facility, :string, read_only: true
        end

          # @!attribute [r] city
          #   @return [String]
          # @!attribute [r] country
          #   @return [String]
          # @!attribute [r] site
          #   @return [Site]
        class Region < APIObject
          attribute :city, :string, read_only: true
          attribute :country, :string, read_only: true
          attribute :site, Site, read_only: true
        end

        attribute :user_name, :string
        attribute :password, :string
        attribute :port, :string
        attribute :host, :string
        attribute :region, Region
        attribute :expires_at, :time
        attribute :created_at, :time, read_only: true
        attribute :updated_at, :time, read_only: true

        resource_type "vpn_sessions"
        resource_path "/vpn_sessions"
        id_prefix     "vpn_"

        extend Operations::List
        extend Operations::Create
        extend Operations::Delete

        class << self
          def refresh_password(id, opts = {})
            parsed = execute_request(method: :patch, path: "#{instance_url(id)}/refresh_password", opts: opts)
            construct_from(parsed, opts: opts)
          end
        end

        def refresh_password(opts = {})
          self.class.refresh_password(id, opts)
        end
      end
    end
  end
end
