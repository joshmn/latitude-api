# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] project
      #   @return [Latitude::API::Objects::Project]
      # @!attribute [rw] period
      #   @return [Period]
      # @!attribute [rw] available_credit_balance
      #   @return [Integer]
      # @!attribute [rw] amount
      #   @return [Integer]
      # @!attribute [rw] price
      #   @return [Integer]
      # @!attribute [rw] products
      #   @return [Array]
      # @!attribute [rw] threshold
      #   @return [Integer]
      class BillingUsage < SingletonAPIResource
          # @!attribute [r] start
          #   @return [Time]
          # @!attribute [r] end
          #   @return [Time]
        class Period < APIObject
          attribute :start, :time, read_only: true
          attribute :end, :time, read_only: true
        end

        attribute :project, Objects::Project
        attribute :period, Period
        attribute :available_credit_balance, :integer
        attribute :amount, :integer
        attribute :price, :integer
        attribute :products, :array
        attribute :threshold, :integer

        resource_type "billing_usage"
        resource_path "/billing/usage"

        class << self
          def retrieve(params = {}, opts = {})
            query = RequestParams.encode(params)
            parsed = execute_request(method: :get, path: resource_path, query: query, opts: opts)
            construct_from(parsed, opts: opts)
          end
        end
      end
    end
  end
end
