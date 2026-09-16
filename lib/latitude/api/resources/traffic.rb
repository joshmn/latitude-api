# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] from_date
      #   @return [Integer]
      # @!attribute [rw] to_date
      #   @return [Integer]
      # @!attribute [rw] total_inbound_gb
      #   @return [Integer]
      # @!attribute [rw] total_outbound_gb
      #   @return [Integer]
      # @!attribute [rw] total_inbound_95th_percentile_mbps
      #   @return [Float]
      # @!attribute [rw] total_outbound_95th_percentile_mbps
      #   @return [Float]
      # @!attribute [rw] regions
      #   @return [Array<Region>]
      class Traffic < SingletonAPIResource
          # @!attribute [r] date
          #   @return [Time]
          # @!attribute [r] inbound_gb
          #   @return [Integer]
          # @!attribute [r] outbound_gb
          #   @return [Integer]
          # @!attribute [r] avg_outbound_speed_mbps
          #   @return [Float]
          # @!attribute [r] avg_inbound_speed_mbps
          #   @return [Float]
        class Data < APIObject
          attribute :date, :time, read_only: true
          attribute :inbound_gb, :integer, read_only: true
          attribute :outbound_gb, :integer, read_only: true
          attribute :avg_outbound_speed_mbps, :float, read_only: true
          attribute :avg_inbound_speed_mbps, :float, read_only: true
        end

          # @!attribute [r] region_slug
          #   @return [String]
          # @!attribute [r] total_inbound_gb
          #   @return [Integer]
          # @!attribute [r] total_outbound_gb
          #   @return [Integer]
          # @!attribute [r] total_inbound_95th_percentile_mbps
          #   @return [Float]
          # @!attribute [r] total_outbound_95th_percentile_mbps
          #   @return [Float]
          # @!attribute [r] data
          #   @return [Array<Data>]
        class Region < APIObject
          attribute :region_slug, :string, read_only: true
          attribute :total_inbound_gb, :integer, read_only: true
          attribute :total_outbound_gb, :integer, read_only: true
          attribute :total_inbound_95th_percentile_mbps, :float, read_only: true
          attribute :total_outbound_95th_percentile_mbps, :float, read_only: true
          attribute :data, [Data], read_only: true
        end

        attribute :from_date, :integer
        attribute :to_date, :integer
        attribute :total_inbound_gb, :integer
        attribute :total_outbound_gb, :integer
        attribute :total_inbound_95th_percentile_mbps, :float
        attribute :total_outbound_95th_percentile_mbps, :float
        attribute :regions, [Region]

        resource_type "traffic"
        resource_path "/traffic"

        class << self
          def retrieve(params = {}, opts = {})
            query = RequestParams.encode(params)
            parsed = execute_request(method: :get, path: resource_path, query: query, opts: opts)
            construct_from(parsed, opts: opts)
          end

          def quota(opts = {})
            parsed = execute_request(method: :get, path: "#{resource_path}/quota", opts: opts)
            Quota.construct_from(parsed, opts: opts)
          end
        end

        # @!attribute [rw] quota_per_project

        #   @return [Array<QuotaPerProject>]

        class Quota < SingletonAPIResource

            # @!attribute [r] granted

            #   @return [Integer]

            # @!attribute [r] additional

            #   @return [Integer]

            # @!attribute [r] total

            #   @return [Integer]

          class QuotaInTb < APIObject

            attribute :granted, :integer, read_only: true

            attribute :additional, :integer, read_only: true

            attribute :total, :integer, read_only: true

          end


            # @!attribute [r] granted

            #   @return [Integer]

            # @!attribute [r] additional

            #   @return [Integer]

            # @!attribute [r] total

            #   @return [Integer]

          class QuotaInMbp < APIObject

            attribute :granted, :integer, read_only: true

            attribute :additional, :integer, read_only: true

            attribute :total, :integer, read_only: true

          end


            # @!attribute [r] region_id

            #   @return [String]

            # @!attribute [r] price

            #   @return [Integer]

            # @!attribute [r] region_slug

            #   @return [String]

            # @!attribute [r] quota_in_tb

            #   @return [QuotaInTb]

            # @!attribute [r] quota_in_mbps

            #   @return [QuotaInMbp]

          class QuotaPerRegion < APIObject

            attribute :region_id, :string, read_only: true

            attribute :price, :integer, read_only: true

            attribute :region_slug, :string, read_only: true

            attribute :quota_in_tb, QuotaInTb, read_only: true

            attribute :quota_in_mbps, QuotaInMbp, read_only: true

          end


            # @!attribute [r] project_id

            #   @return [String]

            # @!attribute [r] project_slug

            #   @return [String]

            # @!attribute [r] billing_method

            #   @return [String]

            # @!attribute [r] quota_per_region

            #   @return [Array<QuotaPerRegion>]

          class QuotaPerProject < APIObject

            attribute :project_id, :string, read_only: true

            attribute :project_slug, :string, read_only: true

            attribute :billing_method, :string, read_only: true

            attribute :quota_per_region, [QuotaPerRegion], read_only: true

          end


          attribute :quota_per_project, [QuotaPerProject]

          resource_type "traffic_quota"
          resource_path "/traffic/quota"

          class << self
            def retrieve(opts = {})
              parsed = execute_request(method: :get, path: resource_path, opts: opts)
              construct_from(parsed, opts: opts)
            end
          end
        end
      end
    end
  end
end
