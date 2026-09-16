# frozen_string_literal: true

module Latitude
  module API
    module Resources
      # @!attribute [rw] slug
      #   @return [String]
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] features
      #   @return [Array]
      # @!attribute [rw] specs
      #   @return [Spec]
      # @!attribute [rw] regions
      #   @return [Array<Region>]
      class Plan < APIResource
          # @!attribute [r] type
          #   @return [String]
          # @!attribute [r] clock
          #   @return [Float]
          # @!attribute [r] cores
          #   @return [Integer]
          # @!attribute [r] count
          #   @return [Integer]
        class Cpu < APIObject
          attribute :type, :string, read_only: true
          attribute :clock, :float, read_only: true
          attribute :cores, :integer, read_only: true
          attribute :count, :integer, read_only: true
        end

          # @!attribute [r] total
          #   @return [Integer]
        class Memory < APIObject
          attribute :total, :integer, read_only: true
        end

          # @!attribute [r] count
          #   @return [Integer]
          # @!attribute [r] size
          #   @return [String]
          # @!attribute [r] type
          #   @return [String]
        class Drive < APIObject
          attribute :count, :integer, read_only: true
          attribute :size, :string, read_only: true
          attribute :type, :string, read_only: true
        end

          # @!attribute [r] count
          #   @return [Integer]
          # @!attribute [r] type
          #   @return [String]
        class Nic < APIObject
          attribute :count, :integer, read_only: true
          attribute :type, :string, read_only: true
        end

          # @!attribute [r] count
          #   @return [Integer]
          # @!attribute [r] type
          #   @return [String]
          # @!attribute [r] vram_per_gpu
          #   @return [String]
          # @!attribute [r] interconnect
          #   @return [String]
        class Gpu < APIObject
          attribute :count, :integer, read_only: true
          attribute :type, :string, read_only: true
          attribute :vram_per_gpu, :string, read_only: true
          attribute :interconnect, :string, read_only: true
        end

          # @!attribute [r] cpu
          #   @return [Cpu]
          # @!attribute [r] memory
          #   @return [Memory]
          # @!attribute [r] drives
          #   @return [Array<Drive>]
          # @!attribute [r] nics
          #   @return [Array<Nic>]
          # @!attribute [r] gpu
          #   @return [Gpu]
        class Spec < APIObject
          attribute :cpu, Cpu, read_only: true
          attribute :memory, Memory, read_only: true
          attribute :drives, [Drive], read_only: true
          attribute :nics, [Nic], read_only: true
          attribute :gpu, Gpu, read_only: true
        end

          # @!attribute [r] available
          #   @return [Array]
          # @!attribute [r] in_stock
          #   @return [Array]
        class Location < APIObject
          attribute :available, :array, read_only: true
          attribute :in_stock, :array, read_only: true
        end

          # @!attribute [r] hour
          #   @return [Integer]
          # @!attribute [r] month
          #   @return [Integer]
          # @!attribute [r] year
          #   @return [Integer]
        class USD < APIObject
          attribute :hour, :integer, read_only: true
          attribute :month, :integer, read_only: true
          attribute :year, :integer, read_only: true
        end

          # @!attribute [r] hour
          #   @return [Integer]
          # @!attribute [r] month
          #   @return [Float]
          # @!attribute [r] year
          #   @return [Integer]
        class BRL < APIObject
          attribute :hour, :integer, read_only: true
          attribute :month, :float, read_only: true
          attribute :year, :integer, read_only: true
        end

          # @!attribute [r] USD
          #   @return [USD]
          # @!attribute [r] BRL
          #   @return [BRL]
        class Pricing < APIObject
          attribute :USD, USD, read_only: true
          attribute :BRL, BRL, read_only: true
        end

          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] deploys_instantly
          #   @return [Array]
          # @!attribute [r] locations
          #   @return [Location]
          # @!attribute [r] stock_level
          #   @return [String]
          # @!attribute [r] pricing
          #   @return [Pricing]
        class Region < APIObject
          attribute :name, :string, read_only: true
          attribute :deploys_instantly, :array, read_only: true
          attribute :locations, Location, read_only: true
          attribute :stock_level, :string, read_only: true
          attribute :pricing, Pricing, read_only: true
        end

        attribute :slug, :string
        attribute :name, :string
        attribute :features, :array
        attribute :specs, Spec
        attribute :regions, [Region]

        resource_type "plans"
        resource_path "/plans"
        id_prefix     "plan_"

        extend Operations::List
        extend Operations::Retrieve

        # @!attribute [rw] name

        #   @return [String]

        # @!attribute [rw] distro

        #   @return [String]

        # @!attribute [rw] slug

        #   @return [String]

        # @!attribute [rw] version

        #   @return [String]

        # @!attribute [rw] user

        #   @return [String]

        # @!attribute [rw] features

        #   @return [Feature]

        # @!attribute [rw] provisionable_on

        #   @return [Array]

        class OperatingSystem < APIResource


          class Feature < APIObject


          end


          attribute :name, :string

          attribute :distro, :string

          attribute :slug, :string

          attribute :version, :string

          attribute :user, :string

          attribute :features, Feature

          attribute :provisionable_on, :array

          resource_type "operating_system"
          resource_path "/plans/operating_systems"

          extend Operations::List
        end

        # @!attribute [rw] region

        #   @return [String]

        # @!attribute [rw] locations

        #   @return [Array]

        # @!attribute [rw] pricing

        #   @return [Pricing]

        class Bandwidth < APIResource

            # @!attribute [r] monthly

            #   @return [Integer]

            # @!attribute [r] yearly

            #   @return [Integer]

          class Usd < APIObject

            attribute :monthly, :integer, read_only: true

            attribute :yearly, :integer, read_only: true

          end


            # @!attribute [r] monthly

            #   @return [Integer]

            # @!attribute [r] yearly

            #   @return [String]

          class Brl < APIObject

            attribute :monthly, :integer, read_only: true

            attribute :yearly, :string, read_only: true

          end


            # @!attribute [r] usd

            #   @return [Usd]

            # @!attribute [r] brl

            #   @return [Brl]

          class Pricing < APIObject

            attribute :usd, Usd, read_only: true

            attribute :brl, Brl, read_only: true

          end


          attribute :region, :string

          attribute :locations, :array

          attribute :pricing, Pricing

          resource_type "bandwidth_plan"
          resource_path "/plans/bandwidth"

          extend Operations::List

          class << self
            def update_packages(attributes = {}, opts = {})
              body = JSONAPI.encode(type: "bandwidth_packages", attributes: attributes)
              execute_request(method: :post, path: resource_path, body: body, opts: opts)
            end
          end
        end

        # @!attribute [rw] name

        #   @return [String]

        # @!attribute [rw] regions

        #   @return [Array<Region>]

        class Storage < APIResource

            # @!attribute [r] month

            #   @return [Float]

          class USD < APIObject

            attribute :month, :float, read_only: true

          end


            # @!attribute [r] month

            #   @return [Float]

          class BRL < APIObject

            attribute :month, :float, read_only: true

          end


            # @!attribute [r] USD

            #   @return [USD]

            # @!attribute [r] BRL

            #   @return [BRL]

          class Pricing < APIObject

            attribute :USD, USD, read_only: true

            attribute :BRL, BRL, read_only: true

          end


            # @!attribute [r] name

            #   @return [String]

            # @!attribute [r] locations

            #   @return [Array]

            # @!attribute [r] pricing

            #   @return [Pricing]

          class Region < APIObject

            attribute :name, :string, read_only: true

            attribute :locations, :array, read_only: true

            attribute :pricing, Pricing, read_only: true

          end


          attribute :name, :string

          attribute :regions, [Region]

          resource_type "storage_plans"
          resource_path "/plans/storage"

          extend Operations::List
        end

        # @!attribute [rw] name

        #   @return [String]

        # @!attribute [rw] specs

        #   @return [Spec]

        # @!attribute [rw] regions

        #   @return [Array<Region>]

        # @!attribute [rw] stock_level

        #   @return [String]

        # @!attribute [rw] available_operating_systems

        #   @return [Array]

        class VirtualMachine < APIResource

            # @!attribute [r] count

            #   @return [Integer]

            # @!attribute [r] clock

            #   @return [Float]

            # @!attribute [r] type

            #   @return [String]

          class Vcpu < APIObject

            attribute :count, :integer, read_only: true

            attribute :clock, :float, read_only: true

            attribute :type, :string, read_only: true

          end


            # @!attribute [r] type

            #   @return [String]

            # @!attribute [r] count

            #   @return [String]

          class Nic < APIObject

            attribute :type, :string, read_only: true

            attribute :count, :string, read_only: true

          end


            # @!attribute [r] amount

            #   @return [Integer]

            # @!attribute [r] unit

            #   @return [String]

          class Size < APIObject

            attribute :amount, :integer, read_only: true

            attribute :unit, :string, read_only: true

          end


            # @!attribute [r] type

            #   @return [String]

            # @!attribute [r] size

            #   @return [Size]

          class Disk < APIObject

            attribute :type, :string, read_only: true

            attribute :size, Size, read_only: true

          end


            # @!attribute [r] memory

            #   @return [Integer]

            # @!attribute [r] gpu

            #   @return [String]

            # @!attribute [r] vram_per_gpu

            #   @return [Integer]

            # @!attribute [r] vcpus

            #   @return [Integer]

            # @!attribute [r] vcpu

            #   @return [Vcpu]

            # @!attribute [r] nics

            #   @return [Array<Nic>]

            # @!attribute [r] disk

            #   @return [Disk]

          class Spec < APIObject

            attribute :memory, :integer, read_only: true

            attribute :gpu, :string, read_only: true

            attribute :vram_per_gpu, :integer, read_only: true

            attribute :vcpus, :integer, read_only: true

            attribute :vcpu, Vcpu, read_only: true

            attribute :nics, [Nic], read_only: true

            attribute :disk, Disk, read_only: true

          end


            # @!attribute [r] available

            #   @return [Array]

            # @!attribute [r] in_stock

            #   @return [Array]

          class Location < APIObject

            attribute :available, :array, read_only: true

            attribute :in_stock, :array, read_only: true

          end


            # @!attribute [r] hour

            #   @return [Integer]

            # @!attribute [r] month

            #   @return [Integer]

            # @!attribute [r] year

            #   @return [Integer]

          class USD < APIObject

            attribute :hour, :integer, read_only: true

            attribute :month, :integer, read_only: true

            attribute :year, :integer, read_only: true

          end


            # @!attribute [r] hour

            #   @return [Integer]

            # @!attribute [r] month

            #   @return [Integer]

            # @!attribute [r] year

            #   @return [Integer]

          class BRL < APIObject

            attribute :hour, :integer, read_only: true

            attribute :month, :integer, read_only: true

            attribute :year, :integer, read_only: true

          end


            # @!attribute [r] USD

            #   @return [USD]

            # @!attribute [r] BRL

            #   @return [BRL]

          class Pricing < APIObject

            attribute :USD, USD, read_only: true

            attribute :BRL, BRL, read_only: true

          end


            # @!attribute [r] name

            #   @return [String]

            # @!attribute [r] locations

            #   @return [Location]

            # @!attribute [r] stock_level

            #   @return [String]

            # @!attribute [r] pricing

            #   @return [Pricing]

          class Region < APIObject

            attribute :name, :string, read_only: true

            attribute :locations, Location, read_only: true

            attribute :stock_level, :string, read_only: true

            attribute :pricing, Pricing, read_only: true

          end


          attribute :name, :string

          attribute :specs, Spec

          attribute :regions, [Region]

          attribute :stock_level, :string

          attribute :available_operating_systems, :array

          resource_type "virtual_machine_plans"
          resource_path "/plans/virtual_machines"

          extend Operations::List
        end
      end
    end
  end
end
