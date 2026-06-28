# frozen_string_literal: true

module Latitude
  module API
    module Operations
      module Nested
        def nested_resource(name, class_name:)
          parent_key = path_param_keys_for_parent
          define_singleton_method(name) do |id|
            klass = Object.const_get(class_name)
            NestedAccessor.new(klass: klass, path_params: { parent_key => id })
          end

          define_method(name) do
            klass = Object.const_get(class_name)
            NestedAccessor.new(klass: klass, path_params: { parent_key => @id })
          end
        end

        def path_param_keys_for_parent
          "#{resource_type.sub(/s\z/, '')}_id".to_sym
        end
      end

      class NestedAccessor
        def initialize(klass:, path_params:)
          @klass = klass
          @path_params = path_params
        end

        def list(params = {}, opts = {})
          @klass.list(params.merge(@path_params), opts, path_params: @path_params)
        end

        def retrieve(id, params = {}, opts = {})
          @klass.retrieve(id, params.merge(@path_params), opts)
        end

        def create(params = {}, opts = {})
          @klass.create(params.merge(@path_params), opts)
        end

        def update(id, params = {}, opts = {})
          @klass.update(id, params.merge(@path_params), opts)
        end

        def delete(id, params = {}, opts = {})
          @klass.delete(id, params.merge(@path_params), opts)
        end
      end
    end
  end
end
