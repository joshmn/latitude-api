# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] slug
      #   @return [String]
      # @!attribute [rw] facility
      #   @return [String]
      # @!attribute [rw] country
      #   @return [Country]
      # @!attribute [rw] type
      #   @return [String]
      class Region < APIResource
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] slug
          #   @return [String]
        class Country < APIObject
          attribute :name, :string, read_only: true
          attribute :slug, :string, read_only: true
        end

        attribute :name, :string
        attribute :slug, :string
        attribute :facility, :string
        attribute :country, Country
        attribute :type, :string

        resource_type "regions"
        resource_path "/regions"
        id_prefix     "reg_"

        extend Operations::List
        extend Operations::Retrieve
      end
    end
  end
end
